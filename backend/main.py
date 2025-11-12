"""
Handles session management, WebSocket signaling, and pose data export
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Dict, List, Optional
import json
import asyncio
from datetime import datetime
import random
import string

app = FastAPI(title="Physio Platform API")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage
sessions: Dict[str, dict] = {}
active_connections: Dict[str, Dict[str, WebSocket]] = {}
pose_data_storage: Dict[str, List[dict]] = {}


# Pydantic Models
class SessionCreate(BaseModel):
    therapist_name: str


class SessionJoin(BaseModel):
    session_code: str
    patient_name: str


class FeedbackMessage(BaseModel):
    session_code: str
    patient_id: str
    message: str


class PoseDataSubmit(BaseModel):
    session_code: str
    user_id: str
    pose_data: dict
    timestamp: float


def generate_session_code(length: int = 6) -> str:
    """Generate a unique session code"""
    while True:
        code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))
        if code not in sessions:
            return code


@app.get("/")
async def root():
    return {"message": "Physiotherapy Platform API", "version": "1.0.0"}


@app.post("/api/sessions/create")
async def create_session(session_data: SessionCreate):
    """Create a new therapy session"""
    session_code = generate_session_code()
    
    session = {
        "code": session_code,
        "therapist_name": session_data.therapist_name,
        "therapist_id": f"therapist_{session_code}",
        "patients": {},
        "created_at": datetime.now().isoformat(),
        "status": "active"
    }
    
    sessions[session_code] = session
    active_connections[session_code] = {}
    pose_data_storage[session_code] = []
    
    return {
        "session_code": session_code,
        "therapist_id": session["therapist_id"],
        "message": "Session created successfully"
    }


@app.post("/api/sessions/join")
async def join_session(join_data: SessionJoin):
    """Patient joins an existing session"""
    session_code = join_data.session_code
    
    if session_code not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session = sessions[session_code]
    
    # Check if session is full (max 3 patients)
    if len(session["patients"]) >= 3:
        raise HTTPException(status_code=400, detail="Session is full")
    
    # Generate patient ID
    patient_id = f"patient_{len(session['patients']) + 1}_{session_code}"
    
    # Add patient to session
    session["patients"][patient_id] = {
        "name": join_data.patient_name,
        "joined_at": datetime.now().isoformat(),
        "accuracy_scores": [],
        "pose_data": []
    }
    
    return {
        "session_code": session_code,
        "patient_id": patient_id,
        "message": "Joined session successfully"
    }


@app.get("/api/sessions/{session_code}")
async def get_session(session_code: str):
    """Get session details"""
    if session_code not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    return sessions[session_code]


@app.post("/api/sessions/{session_code}/end")
async def end_session(session_code: str):
    """End a session and generate report"""
    if session_code not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session = sessions[session_code]
    session["status"] = "ended"
    session["ended_at"] = datetime.now().isoformat()
    
    # Generate report
    report = generate_session_report(session_code)
    
    # Notify all connected clients
    if session_code in active_connections:
        for ws in active_connections[session_code].values():
            try:
                await ws.send_json({
                    "type": "session_ended",
                    "report": report
                })
            except:
                pass
    
    return report


@app.post("/api/pose-data")
async def submit_pose_data(data: PoseDataSubmit):
    """Store pose data for a patient"""
    session_code = data.session_code
    
    if session_code not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    # Store pose data
    pose_entry = {
        "user_id": data.user_id,
        "timestamp": data.timestamp,
        "pose_data": data.pose_data
    }
    
    pose_data_storage[session_code].append(pose_entry)
    
    # Update patient's pose data in session
    session = sessions[session_code]
    if data.user_id in session["patients"]:
        session["patients"][data.user_id]["pose_data"].append(pose_entry)
        
        # Update accuracy score if available
        if "accuracy" in data.pose_data:
            session["patients"][data.user_id]["accuracy_scores"].append(
                data.pose_data["accuracy"]
            )
    
    return {"status": "success"}


@app.get("/api/sessions/{session_code}/report")
async def get_session_report(session_code: str):
    """Get session report with pose data"""
    if session_code not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    return generate_session_report(session_code)


def generate_session_report(session_code: str) -> dict:
    """Generate comprehensive session report"""
    session = sessions[session_code]
    
    report = {
        "session_code": session_code,
        "therapist_name": session["therapist_name"],
        "created_at": session["created_at"],
        "ended_at": session.get("ended_at", datetime.now().isoformat()),
        "patients": []
    }
    
    # Process each patient's data
    for patient_id, patient_data in session["patients"].items():
        accuracy_scores = patient_data["accuracy_scores"]
        
        patient_report = {
            "patient_id": patient_id,
            "patient_name": patient_data["name"],
            "joined_at": patient_data["joined_at"],
            "total_frames": len(patient_data["pose_data"]),
            "average_accuracy": sum(accuracy_scores) / len(accuracy_scores) if accuracy_scores else 0,
            "min_accuracy": min(accuracy_scores) if accuracy_scores else 0,
            "max_accuracy": max(accuracy_scores) if accuracy_scores else 0,
            "common_errors": analyze_common_errors(patient_data["pose_data"]),
            "pose_data_summary": {
                "total_samples": len(patient_data["pose_data"]),
                "sample_poses": patient_data["pose_data"][:10]  # First 10 samples
            }
        }
        
        report["patients"].append(patient_report)
    
    return report


def analyze_common_errors(pose_data: List[dict]) -> List[str]:
    """Analyze pose data to identify common errors"""
    error_counts = {}
    
    for entry in pose_data:
        if "errors" in entry.get("pose_data", {}):
            for error in entry["pose_data"]["errors"]:
                error_counts[error] = error_counts.get(error, 0) + 1
    
    # Sort errors by frequency
    sorted_errors = sorted(error_counts.items(), key=lambda x: x[1], reverse=True)
    
    # Return top 5 most common errors
    return [error for error, count in sorted_errors[:5]]


# WebSocket Connection Manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, session_code: str, user_id: str):
        await websocket.accept()
        if session_code not in self.active_connections:
            self.active_connections[session_code] = {}
        self.active_connections[session_code][user_id] = websocket
    
    def disconnect(self, session_code: str, user_id: str):
        if session_code in self.active_connections:
            if user_id in self.active_connections[session_code]:
                del self.active_connections[session_code][user_id]
    
    async def send_personal_message(self, message: dict, session_code: str, user_id: str):
        if session_code in self.active_connections:
            if user_id in self.active_connections[session_code]:
                await self.active_connections[session_code][user_id].send_json(message)
    
    async def broadcast(self, message: dict, session_code: str, exclude_user: Optional[str] = None):
        if session_code in self.active_connections:
            for user_id, connection in self.active_connections[session_code].items():
                if user_id != exclude_user:
                    try:
                        await connection.send_json(message)
                    except:
                        pass


manager = ConnectionManager()


@app.websocket("/ws/{session_code}/{user_id}")
async def websocket_endpoint(websocket: WebSocket, session_code: str, user_id: str):
    """WebSocket endpoint for real-time communication"""
    await manager.connect(websocket, session_code, user_id)
    
    try:
        # Notify others that a user joined
        await manager.broadcast(
            {
                "type": "user_joined",
                "user_id": user_id,
                "session_code": session_code
            },
            session_code,
            exclude_user=user_id
        )
        
        while True:
            data = await websocket.receive_json()
            message_type = data.get("type")
            
            # Handle different message types
            if message_type == "webrtc_signal":
                # Forward WebRTC signaling data
                target_user = data.get("target_user")
                if target_user:
                    await manager.send_personal_message(
                        {
                            "type": "webrtc_signal",
                            "from_user": user_id,
                            "signal": data.get("signal")
                        },
                        session_code,
                        target_user
                    )
            
            elif message_type == "feedback":
                # Therapist sending feedback to patient
                target_patient = data.get("target_patient")
                if target_patient:
                    await manager.send_personal_message(
                        {
                            "type": "feedback",
                            "message": data.get("message"),
                            "from": user_id
                        },
                        session_code,
                        target_patient
                    )
            
            elif message_type == "pose_update":
                # Broadcast pose updates to therapist
                if session_code in sessions:
                    session = sessions[session_code]
                    therapist_id = session["therapist_id"]
                    
                    await manager.send_personal_message(
                        {
                            "type": "pose_update",
                            "user_id": user_id,
                            "pose_data": data.get("pose_data")
                        },
                        session_code,
                        therapist_id
                    )
            
            elif message_type == "accuracy_update":
                # Update accuracy scores
                if session_code in sessions:
                    session = sessions[session_code]
                    if user_id in session["patients"]:
                        accuracy = data.get("accuracy", 0)
                        session["patients"][user_id]["accuracy_scores"].append(accuracy)
                        
                        # Broadcast to therapist
                        therapist_id = session["therapist_id"]
                        await manager.send_personal_message(
                            {
                                "type": "accuracy_update",
                                "user_id": user_id,
                                "accuracy": accuracy
                            },
                            session_code,
                            therapist_id
                        )
    
    except WebSocketDisconnect:
        manager.disconnect(session_code, user_id)
        
        # Notify others that user left
        await manager.broadcast(
            {
                "type": "user_left",
                "user_id": user_id
            },
            session_code
        )
    
    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(session_code, user_id)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
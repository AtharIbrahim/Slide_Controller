#!/usr/bin/env python3
"""
Simple and Reliable Slide Controller Server
This version focuses on connection stability and basic functionality.
"""

import asyncio
import json
import logging
import socket
import pyautogui
import time
from websockets.server import serve
from websockets.exceptions import ConnectionClosed, WebSocketException

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class SimpleSlideController:
    def __init__(self):
        # Disable pyautogui's fail-safe for presentations
        pyautogui.FAILSAFE = False
        pyautogui.PAUSE = 0.1
        
        self.connected_clients = set()
        logger.info("🎯 Simple Slide Controller initialized")
    
    def get_local_ip(self):
        """Get the local IP address"""
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.connect(("8.8.8.8", 80))
                return s.getsockname()[0]
        except Exception:
            return "127.0.0.1"
    
    async def handle_client(self, websocket, path):
        """Handle client connections and commands"""
        client_ip = websocket.remote_address[0]
        logger.info(f"📱 Client connected from {client_ip}")
        
        self.connected_clients.add(websocket)
        
        try:
            # Send welcome message
            await websocket.send(json.dumps({
                "type": "welcome",
                "message": "Connected to Slide Controller",
                "server_ip": self.get_local_ip()
            }))
            
            async for message in websocket:
                try:
                    data = json.loads(message)
                    command = data.get('command')
                    
                    if command == 'heartbeat':
                        # Respond to heartbeat
                        await websocket.send(json.dumps({
                            "type": "heartbeat_response",
                            "timestamp": time.time()
                        }))
                        continue
                    
                    logger.info(f"📡 Command received: {command}")
                    
                    # Execute command
                    if command == 'next':
                        pyautogui.press('right')
                        logger.info("➡️ Next slide")
                    elif command == 'previous':
                        pyautogui.press('left')
                        logger.info("⬅️ Previous slide")
                    elif command == 'start_presentation':
                        pyautogui.press('f5')
                        logger.info("🚀 Start presentation")
                    elif command == 'end_presentation':
                        pyautogui.press('escape')
                        logger.info("🛑 End presentation")
                    elif command == 'volume_up':
                        pyautogui.press('volumeup')
                        logger.info("🔊 Volume up")
                    elif command == 'volume_down':
                        pyautogui.press('volumedown')
                        logger.info("🔉 Volume down")
                    elif command == 'volume_mute':
                        pyautogui.press('volumemute')
                        logger.info("🔇 Volume mute")
                    elif command == 'laser_pointer_toggle':
                        # Ctrl+L is common for laser pointer in PowerPoint
                        pyautogui.hotkey('ctrl', 'l')
                        logger.info("🔴 Laser pointer toggle")
                    elif command == 'laser_pointer':
                        # Alternative laser pointer command
                        pyautogui.hotkey('ctrl', 'l')
                        logger.info("🔴 Laser pointer toggle")
                    elif command == 'black_screen':
                        pyautogui.press('b')
                        logger.info("⚫ Black screen toggle")
                    elif command == 'white_screen':
                        pyautogui.press('w')
                        logger.info("⚪ White screen toggle")
                    elif command == 'presentation_view':
                        pyautogui.press('f5')
                        logger.info("📺 Presentation view")
                    elif command == 'first_slide':
                        pyautogui.press('home')
                        logger.info("⏮️ First slide")
                    elif command == 'last_slide':
                        pyautogui.press('end')
                        logger.info("⏭️ Last slide")
                    elif command == 'toggle_mute':
                        pyautogui.press('volumemute')
                        logger.info("🔇 Toggle mute")
                    elif command == 'mute':
                        pyautogui.press('volumemute')
                        logger.info("🔇 Mute toggle")
                    else:
                        logger.warning(f"❓ Unknown command: {command}")
                    
                    # Send acknowledgment
                    await websocket.send(json.dumps({
                        "type": "command_ack",
                        "command": command,
                        "status": "executed"
                    }))
                    
                except json.JSONDecodeError:
                    logger.error("❌ Invalid JSON received")
                except Exception as e:
                    logger.error(f"❌ Error processing command: {e}")
                    
        except ConnectionClosed:
            logger.info(f"📱 Client {client_ip} disconnected normally")
        except WebSocketException as e:
            logger.warning(f"📱 Client {client_ip} disconnected with error: {e}")
        except Exception as e:
            logger.error(f"❌ Unexpected error with client {client_ip}: {e}")
        finally:
            self.connected_clients.discard(websocket)
            logger.info(f"📱 Client {client_ip} removed from active connections")

async def main():
    """Main server function"""
    controller = SimpleSlideController()
    local_ip = controller.get_local_ip()
    port = 8080
    
    logger.info("=" * 60)
    logger.info("🎯 SIMPLE SLIDE CONTROLLER SERVER")
    logger.info("=" * 60)
    logger.info(f"📱 Server starting on: {local_ip}:{port}")
    logger.info(f"🌐 WebSocket URL: ws://{local_ip}:{port}")
    logger.info("=" * 60)
    logger.info("📋 SETUP INSTRUCTIONS:")
    logger.info("1. 📊 Open PowerPoint presentation")
    logger.info("2. 🖱️ Click on PowerPoint to make it active")
    logger.info("3. 📱 Connect your phone using the IP above")
    logger.info("4. 🎮 Use the app to control slides")
    logger.info("=" * 60)
    logger.info("🎮 SUPPORTED COMMANDS:")
    logger.info("• next/previous - Navigate slides")
    logger.info("• start_presentation/end_presentation - F5/Esc")
    logger.info("• volume_up/volume_down/volume_mute - Audio control")
    logger.info("• laser_pointer_toggle - Ctrl+L")
    logger.info("• black_screen/white_screen - B/W keys")
    logger.info("• first_slide/last_slide - Home/End keys")
    logger.info("• presentation_view - F5")
    logger.info("=" * 60)
    logger.info("Press Ctrl+C to stop the server")
    logger.info("=" * 60)
    
    try:
        async with serve(
            controller.handle_client, 
            "0.0.0.0", 
            port,
            ping_interval=20,
            ping_timeout=10,
            close_timeout=5
        ):
            logger.info("🚀 Server is running and ready for connections!")
            await asyncio.Future()  # Run forever
            
    except KeyboardInterrupt:
        logger.info("🛑 Server stopped by user")
    except Exception as e:
        logger.error(f"❌ Server error: {e}")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("🛑 Server stopped")
    except Exception as e:
        logger.error(f"❌ Failed to start server: {e}")

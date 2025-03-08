from flask import Flask, request, jsonify
import cv2
from keras.models import model_from_json
import numpy as np
import threading

app = Flask(__name__)

def load_model():
    global model, face_cascade, labels
    json_file = open("facialemotionmodel.json", "r")
    model_json = json_file.read()
    json_file.close()
    model = model_from_json(model_json)
    model.load_weights("facialemotionmodel.h5")
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    labels = {0: 'angry', 1: 'disgust', 2: 'fear', 3: 'happy', 4: 'neutral', 5: 'sad', 6: 'surprise'}

load_model()

def detect_emotion():
    webcam = cv2.VideoCapture(0)
    while True:
        _, frame = webcam.read()
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.3, 5)
        for (x, y, w, h) in faces:
            roi_gray = gray[y:y+h, x:x+w]
            roi_gray = cv2.resize(roi_gray, (48, 48))
            roi_gray = roi_gray.reshape(1, 48, 48, 1) / 255.0
            prediction = model.predict(roi_gray)
            emotion_label = labels[np.argmax(prediction)]
            return emotion_label

def start_emotion_detection():
    global detected_emotion
    detected_emotion = detect_emotion()

@app.route("/get_emotion", methods=["GET"])
def get_emotion():
    return jsonify({"emotion": detected_emotion})

if __name__ == "__main__":
    threading.Thread(target=start_emotion_detection, daemon=True).start()
    app.run(host="0.0.0.0", port=5000)

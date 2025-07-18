from ultralytics import YOLO
import cv2

# 공식 yolov8n 모델 로드 (인터넷에서 자동 다운로드됨)
model = YOLO("yolov8n.pt")

# 웹캠 열기 (기본 카메라: 0)
cap = cv2.VideoCapture(1)

if not cap.isOpened():
    print("웹캠을 열 수 없습니다.")
    exit()

while True:
    ret, frame = cap.read()
    if not ret:
        print("프레임을 읽을 수 없습니다.")
        break

    # YOLO 예측 (conf=0.3 이상 탐지)
    results = model.predict(source=frame, conf=0.3, verbose=False)

    # 결과 시각화
    for result in results:
        boxes = result.boxes.xyxy.cpu().numpy().astype(int)
        classes = result.boxes.cls.cpu().numpy().astype(int)
        for box, cls in zip(boxes, classes):
            x1, y1, x2, y2 = box
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
            label = model.names[cls] if hasattr(model, "names") else str(cls)
            cv2.putText(frame, label, (x1, y1 - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

    # 화면 출력
    cv2.imshow("YOLOv8n Webcam Detection", frame)

    # 'q' 키 누르면 종료
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# 정리
cap.release()
cv2.destroyAllWindows()

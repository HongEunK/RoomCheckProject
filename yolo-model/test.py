from ultralytics import YOLO
import cv2

# 공식 yolov8n 모델 로드 (인터넷에서 자동 다운로드됨)
model = YOLO("yolov8n.pt")

# 이미지 파일 경로 지정
image_path = "test.jpg"  # 본인 이미지 경로로 변경하세요

# 이미지 읽기
image = cv2.imread("/Users/eunhong/Projects/OpenSWProject/yolo-model/test.jpg")

if image is None:
    print("이미지를 불러올 수 없습니다. 경로를 확인하세요.")
    exit()

# 예측 수행 (conf=0.3 이상만 탐지)
results = model.predict(source=image, conf=0.3, verbose=False)

# 탐지 결과 시각화
for result in results:
    boxes = result.boxes.xyxy.cpu().numpy().astype(int)
    classes = result.boxes.cls.cpu().numpy().astype(int)
    for box, cls in zip(boxes, classes):
        x1, y1, x2, y2 = box
        cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 2)
        label = model.names[cls] if hasattr(model, "names") else str(cls)
        cv2.putText(image, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

# 결과 출력
cv2.imshow("YOLOv8n Detection", image)
cv2.waitKey(0)
cv2.destroyAllWindows()

# 탐지된 박스와 클래스 출력
print("Detected boxes and classes:")
for result in results:
    boxes = result.boxes.xyxy.cpu().numpy().astype(int)
    classes = result.boxes.cls.cpu().numpy().astype(int)
    for box, cls in zip(boxes, classes):
        print(f"Class: {model.names[cls]}, Box: {box}")

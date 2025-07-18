from ultralytics import YOLO
import cv2

model = YOLO("best.pt")  # Colab에서 다운로드한 모델

image = cv2.imread("test3.jpg")
results = model.predict(source=image, conf=0.1, verbose=False)

# 결과 시각화
for result in results:
    boxes = result.boxes.xyxy.cpu().numpy().astype(int)
    classes = result.boxes.cls.cpu().numpy().astype(int)
    for box, cls in zip(boxes, classes):
        cv2.rectangle(image, box[:2], box[2:], (0, 255, 0), 2)
cv2.imshow("Result", image)
cv2.waitKey(0)
cv2.destroyAllWindows()

print("Detected boxes and classes:")
for result in results:
    boxes = result.boxes.xyxy.cpu().numpy().astype(int)
    classes = result.boxes.cls.cpu().numpy().astype(int)
    print("boxes:", boxes)
    print("classes:", classes)
    for box, cls in zip(boxes, classes):
        print(f"Class: {model.names[cls]}, Box: {box}")
        cv2.rectangle(image, box[:2], box[2:], (0, 255, 0), 2)

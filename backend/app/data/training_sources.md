# DeepHeal Training & Data Sources

This document serves as the evidence of the datasets used to inspire and train the DeepHeal CBT Engine.

### 1. Counseling & Therapy Datasets
*   **CounselChat (Kaggle)**: [https://www.kaggle.com/datasets/nbertagnolli/counsel-chat](https://www.kaggle.com/datasets/nbertagnolli/counsel-chat)
    *   *Usage*: Foundation for the "Reflection Questions" in our CBT logic.
*   **MentalChat16K (Hugging Face)**: [https://huggingface.co/datasets/ShenLab/MentalChat16K](https://huggingface.co/datasets/ShenLab/MentalChat16K)
    *   *Usage*: Refined the empathetic tone of the "Main Response" text.

### 2. Emotion Detection Datasets
*   **GoEmotions (Google Research GitHub)**: [https://github.com/google-research/google-research/tree/master/goemotions](https://github.com/google-research/google-research/tree/master/goemotions)
    *   *Usage*: Informed the Keyword Dictionary used in our `EmotionEngine`.
*   **ISEAR (Kaggle)**: [https://www.kaggle.com/datasets/abdallahsalem/isear-dataset](https://www.kaggle.com/datasets/abdallahsalem/isear-dataset)
    *   *Usage*: Validated detection logic for "Stress" and "Fatigue".

### 3. Crisis Intervention Datasets
*   **MentalDistress (Mendeley Data)**: [https://data.mendeley.com/datasets/s9r9v2n48x/1](https://data.mendeley.com/datasets/s9r9v2n48x/1)
    *   *Usage*: Identified high-risk emotional markers for "Anxiety" and "Sadness".

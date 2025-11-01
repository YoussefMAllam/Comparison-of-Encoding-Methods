# 📘 Comparison of Coding Methods Using MATLAB

### CIE 425: Information Theory and Coding  
**Authors:** Aml Tarek · Mohammad Mahmoud · Youssef Allam  

---

## 📖 Project Overview
This project compares different **source coding methods** — specifically **Fixed-Length Coding**, **Huffman Coding**, and **Fano Coding** — implemented in **MATLAB**.  
The objective is to analyze the performance of each method in terms of **compression efficiency**, **entropy**, and **average code length** for both **uniform** and **arbitrary symbol distributions**, as well as for **real-world text data**.

---

## 🧠 Objectives
- Implement and compare **Fixed-Length**, **Huffman**, and **Fano** coding techniques.  
- Analyze how each coding method performs with **uniform** and **non-uniform symbol distributions**.  
- Apply Huffman and Fano coding to **real text files** to evaluate practical compression rates.  
- Interpret results based on **entropy** and **average code length**.

---

## ⚙️ Implementation Details

### Part 1: Uniform Discrete Distribution
- Tested with symbol counts **M = 4, 6, 8**.  
- Compared total and average code lengths for each method.  

**Observations:**
- When **M** is a power of 2, **fixed-length coding** is already optimal.  
- When **M** is *not* a power of 2 (e.g., M = 6), **Huffman coding** provides higher efficiency.

---

### Part 2: Arbitrary Distributions
- Applied the same process to **non-uniform symbol distributions** (datasets Y and Z).  

| Dataset | Entropy (bits/symbol) | Fixed Coding (bits/symbol) | Huffman Coding (bits/symbol) | Observation |
|:---------|:----------------------|:----------------------------|:------------------------------|:-------------|
| **Y** | 1.94 | 3.00 | 1.94 | Highly skewed → Huffman near optimal |
| **Z** | 2.39 | 3.00 | 2.45 | Less skewed → Moderate improvement |

---

### Part 3: Huffman Encoding of Text File
Encoded a text file and compared results with ASCII representation.

| Metric | ASCII | Huffman | Compression |
|:-------|:------|:---------|:-------------|
| Bits Used | 49,656 | 26,436 | **46.76% smaller** |

**Conclusion:**  
Huffman coding achieved strong compression, confirming the skewed probability distribution of real text.

---

### Part 4: Fano Encoding
Performed similar encoding with **Fano coding** for comparison.

| Metric | ASCII | Fano | Compression |
|:-------|:------|:------|:-------------|
| Bits Used | 49,656 | 27,662 | **44.29% smaller** |

**Conclusion:**  
- **Huffman** outperforms **Fano** in compression efficiency.  
- **Fano** remains valuable for its **simplicity** and **low computational complexity**.

---

## 🧩 Key Takeaways
- **Huffman coding** provides near-optimal compression for non-uniform distributions.  
- **Fixed-length coding** is efficient only when the number of symbols is a power of two.  
- **Fano coding** is easier to implement but slightly less efficient.  
- Practical results match **information theory** predictions on entropy and redundancy.

---

## 📈 Results Summary
| Method | Average Length (bits/symbol) | Compression Efficiency |
|:--------|:-----------------------------|:------------------------|
| Fixed-Length | 3.00 | Baseline |
| Huffman | 2.45 | **High** |
| Fano | 2.76 | Moderate |

---

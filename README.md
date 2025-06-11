# CIS11 Final Project: Test Score Calculator (LC-3 Assembly)

## Course
**CIS 11 – Computer Architecture and Assembly Language Programming**  
**Term:** Spring 2025

## Team Members
- **Diego Cordova** – Lead Programmer, Project Designer, Flowchart Author, Function Architect  
- **Raybert Salazar** – Documentation, Code Comments & Readability Enhancements  
- **Yoonsu Cho** – Design Contribution, Flowchart

## Project Description

This project implements a **Test Score Calculator** in **LC-3 assembly**, designed to:
- Read 5 three-digit test scores from user input (0–100)
- Classify each score into a letter grade (A–F)
- Calculate and display the **average**, **minimum**, and **maximum** scores
- Output all values as readable ASCII on the console

It demonstrates the following LC-3 concepts:
- Use of **subroutines**, **branching**, and **conditionals**
- Manual **stack management** using PUSH/POP
- **ASCII conversion** for number output
- Pointer and array handling with `STR`, `LDR`, `LEA`, and `ADD`
- Offset management (9-bit PC-relative addressing)

---

## How to Run the Program

###  Requirements
- LC-3 Simulator (LC3Edit + LC3Tools or equivalent)
- `.ASM` file: `TESTSCORE.ASM`

### Steps
1. Open the file in your LC-3 editor.
2. Assemble the program.
3. **Set the starting address to `x2900`.**
4. Run the program.
5. You will be prompted to enter **5 test scores** (e.g., `052`, `087`, etc.).
6. The program will:
   - Print the **letter grade** for each score
   - Display the **average**, **maximum**, and **minimum** scores

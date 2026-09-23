# .NET Practice Repository

<div align="center">
  
  ![.NET](https://img.shields.io/badge/.NET-9.0-512BD4?logo=dotnet&logoColor=white)
  ![C#](https://img.shields.io/badge/C%23-Learning-239120?logo=csharp&logoColor=white)
  ![Auto Push](https://img.shields.io/badge/Auto%20Push-Daily%207%3A45%20PM-brightgreen)
  ![GitHub last commit](https://img.shields.io/github/last-commit/Sailen-Mondal/.NET-Practice)

</div>

A structured learning repository for C# and .NET concepts — from OOP fundamentals to advanced patterns.
Code is automatically committed and pushed to GitHub every day at **7:45 PM IST**.

---

## 📁 Project Structure

```
.NET-Practice/
├── src/
│   ├── 01-OOP-Fundamentals/     # OOP assignments: encapsulation, inheritance, polymorphism, abstraction
│   ├── 02-CSharp-Basics/        # Hello World, constructors, basic syntax
│   └── 03-OOP-Practice/         # OOP practice: partial classes, interfaces, polymorphism
├── scripts/
│   ├── auto_git_push.ps1        # Daily auto-commit & push script (Windows Task Scheduler)
│   └── task_schedule.xml        # Task Scheduler XML definition
├── docs/
│   └── progress.md              # Learning progress tracker
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md
├── .editorconfig                # Consistent code formatting across editors
├── .gitignore                   # C#/.NET specific ignores
└── README.md
```

---

## 🗂️ Learning Modules

### [`src/01-OOP-Fundamentals`](./src/01-OOP-Fundamentals/)
Core OOP assignments covering:

| # | Topic | Files |
|---|-------|-------|
| 1 | Encapsulation | `PaymentProcessor.cs` |
| 2 | Access Modifiers | `PatientRecord.cs` |
| 3 | Inheritance (Hierarchical) | `Employee.cs` |
| 4 | Inheritance (Multilevel) | `Vehicle.cs` |
| 5 | Interfaces | `Notification.cs` |
| 6 | Polymorphism (Method overloading & overriding) | `PolymorphismExamples.cs` |
| 7 | Abstract Classes | `SmartDevice.cs` |
| 8 | Abstract + Polymorphism | `Loan.cs` |
| 9 | Interface segregation | `CloudStorage.cs` |
| 10 | Multiple Interfaces | `WarehouseRobot.cs` |

### [`src/02-CSharp-Basics`](./src/02-CSharp-Basics/)
Fundamental C# concepts — constructors, console I/O, basic program structure.

### [`src/03-OOP-Practice`](./src/03-OOP-Practice/)
Practice projects — partial classes, interfaces, polymorphism in action.

---

## ⚡ Automated Daily Git Push

This repository uses a Windows Task Scheduler task to automatically commit and push any changes every day at **7:45 PM IST**.

### How it works
1. The script [`scripts/auto_git_push.ps1`](./scripts/auto_git_push.ps1) is triggered by Windows Task Scheduler.
2. It checks for any file changes in the repository.
3. If changes exist, it stages all files, commits with a timestamped message, and pushes to GitHub.
4. If the push fails (e.g., network issue), it retries up to **3 times** with a 30-second wait.
5. Execution is logged to `scripts/auto_git_push.log`.

### Key reliability features
- ✅ Runs even if the PC is on battery power
- ✅ Catches up if the scheduled time was missed (e.g., PC was off)
- ✅ Retries push 3× on transient failures
- ✅ Validates git binary existence before running
- ✅ Log rotation (keeps last 500 lines)
- ✅ Writes to Windows Event Log on critical failures

---

## 🚀 Getting Started

### Prerequisites
- [.NET 9.0 SDK](https://dotnet.microsoft.com/download)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) or [VS Code](https://code.visualstudio.com/) with C# extension

### Run a project
```bash
cd src/01-OOP-Fundamentals
dotnet run
```

---

## 📈 Progress

See [`docs/progress.md`](./docs/progress.md) for detailed learning progress tracking.

---

## 📝 Commit Convention

Auto-commits follow the format:
```
chore: auto daily commit [YYYY-MM-DD HH:mm:ss]
```

Manual commits should follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` – new feature or concept added
- `fix:` – bug fix
- `chore:` – maintenance, refactoring
- `docs:` – documentation updates

---

*This is a personal learning repository. Contributions are not expected.*

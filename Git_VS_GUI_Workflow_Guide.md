# The "I Just Want to Code" Git Guide for Visual Studio Users

## Purpose
This guide is designed for developers who are used to **TFS** and just want to check-in their code without dealing with "Merge Commits", command lines, or headaches.

If you follow this **exactly**, Git will feel almost identical to TFS.

---

## 🛑 PART 1: The One-Time Setup (Do this ONCE)

You hate "Merge Commits". They are ugly and confusing. Run this command one time in PowerShell to disable them forever.

```powershell
git config --global pull.rebase true
```

**What this does:**
When you "Get Latest", instead of creating a "Merge Bubble", Git will essentially:
1.  Temporarily "shelve" (stash) your changes.
2.  Download the latest code from the server.
3.  Re-apply your changes on top.
**Result:** A clean, straight line of history. Just like TFS.

---

## 📖 PART 2: TFS to Git Dictionary

| TFS Concept | Visual Studio (Git Changes) | VS Code (Source Control) |
| :--- | :--- | :--- |
| **Get Latest** | **Pull** (Arrow Down) | **Sync** / **Pull** |
| **Check In** | **Commit All & Push** | **Commit** -> **Sync Changes** |
| **Shelve** | **Stash** (Git Menu -> Stash) | **Stash** (Three dots -> Stash) |
| **Unshelve** | **Apply Stash** | **Pop Stash** |
| **Rollback** | **Revert** (Right-click commit) | **Revert Change** |
| **History** | **View History** | **Timeline** View |
| **Resolve Conflict** | **Merge Editor** | **Merge Editor** |

---

## 🛠️ PART 3: Troubleshooting Flowchart (ASCII)

**Problem: "I can't push my code!"**

```text
START: You clicked "Push" (or Sync) and it failed.
  |
  V
[ READ THE ERROR MESSAGE ]
  |
  +--- "Refused because... remote contains work you do not have"
  |      |
  |      +--> SOLUTION: You are behind. Click **PULL** (Get Latest).
  |             |
  |             +--> Did "Pull" work?
  |                    |
  |                    +-- YES: Awesome. Now click **PUSH** again.
  |                    |
  |                    +-- NO: "Conflict detected" ?
  |                          |
  |                          +--> Go to [ CONFLICT RESOLUTION ] section below.
  |
  +--- "Permission denied"
         |
         +--> SOLUTION: Check your VPN / Password.
```

**Problem: "I messed up a file and want to go back!"**

```text
START: The file is broken.
  |
  V
[ HAVE YOU COMMITTED IT? ]
  |
  +--- NO (It's still in "Changes")
  |      |
  |      +--> VS: Right-click file -> **Undo Changes**
  |      +--> VS Code: Click the "Curved Arrow" (Discard Changes) icon.
  |
  +--- YES (It's committed, but not pushed)
         |
         +--> VS: Git Menu -> View History -> Right-click your commit -> **Reset > Keep Changes (Mixed)**
         |    (This "un-commits" it but keeps your file edits so you can fix them).
         |
         +--> VS Code: Undo Last Commit.
```

---

## 🧪 PART 4: Common Scenarios (Generic)

These are the situations you will face every day. You can use these steps on **any** file in your project.

### Scenario 1: The "Happy Path" (Edit & Push)
*Just like "Check In".*
1.  Open a file, make a change.
2.  **VS:** Go to "Git Changes" window.
3.  Enter a message.
4.  Click **Commit All**.
5.  Click **Push** (Up Arrow).
    *   *Note: If `Commit & Push` is available, just click that.*

### Scenario 2: The "Get Latest" (Pull)
*Someone else changed a file on the server.*
1.  You are ready to work, but you are behind.
2.  **VS:** Click **Pull** (or the "Sync" icon).
3.  Git downloads changes and updates your files.
4.  No popups? Good. You are up to date.

### Scenario 3: The "Conflict" (Two people changed the SAME file)
*You changed Line 1. Someone else changed Line 1. Git doesn't know which one you want.*
1.  You try to **Pull**.
2.  Error: "Conflict detected." (Don't panic!)
3.  **VS:** A bar appears: "Conflicts: 1". Click it.
4.  Double-click the file name.
5.  **The "Comparison" Window** (It looks just like the TFS Resolve window):
    *   **Left (Incoming):** What THEY wrote.
    *   **Right (Current):** What YOU wrote.
    *   **Bottom (Result):** The Final Version.
6.  **The Fix:** Check the box next to the code you want to keep.
    *   Want theirs? Check Left.
    *   Want yours? Check Right.
    *   Want both? Check both.
7.  **The Button:** Click **Accept Merge** at the top.
    *   *Translation:* "Accept Merge" just means **"Save Final Version"**.
    *   *Note:* This does NOT create a "Merge Commit" bubble because we are using Rebase. You are safe.
8.  **Commit & Push** the result.

### Scenario 4: The "Undo Pending" (Reverting a mistake)
*You typed garbage in a file.*
1.  **VS:** Right-click the file in "Git Changes".
2.  Select **Undo Changes**.
3.  Confirm. It is back to normal.

### Scenario 5: The "Shelveset" (Stash - Switching Tasks)
*Boss: "Stop working on Feature A, fix a bug now!"*
1.  You have half-finished work.
2.  **VS:** Click the arrow next to "Commit All" -> **Stash All**.
3.  Your changes disappear (saved in a "Stash").
4.  Fix the bug, commit, push.
5.  **VS:** Git Menu -> Manage Stashes -> Right-click your Stash -> **Apply**.
6.  Your changes are back!

### Scenario 6: The "Bad Commit" (Undo Last Checkin)
*You committed a file with a typo, but didn't push.*
1.  **VS:** Git Menu -> View History.
2.  Right-click your top commit.
3.  **Reset** -> **Keep Changes (Mixed)**.
4.  The commit is gone, but your file changes are still there (Pending).
5.  Fix the typo. Commit again.

### Scenario 7: The "Rollback" (Revert Pushed Code)
*You pushed a bug and everyone has it. You need to "Undo" it without breaking the linear history.*
1.  **VS:** Git Menu -> View History.
2.  Find the bad commit (e.g., "Added broken feature").
3.  Right-click it -> **Revert**.
    *   *What happens:* Git creates a **NEW** commit on top of the list.
    *   *The Magic:* This new commit is the exact "Mathematical Opposite" of the bad one. It deletes what you added, and adds what you deleted.
4.  **Push** this new "Revert commit".
5.  **Result:** History stays straight. No branches. No merges. You just added a "fix" on top.

### Scenario 8: The "Partial Commit" (Changes in 2 files, commit only 1)
*You changed `FileA` and `FileB`. You only want to check in `FileA`.*
1.  **VS:** In the "Changes" list.
2.  Hover over `FileB`. Click the "-" (Stage/Unstage) button.
3.  `FileB` moves to "Changes" (Unstaged). `FileA` is in "Staged Changes".
4.  Commit. Only `FileA` goes. `FileB` stays pending.

### Scenario 9: The "Blame" (Who wrote this garbage?)
*A file is broken.*
1.  **VS:** Right-click inside the text editor on the file.
2.  Select **Git** -> **Blame (Annotate)**.
3.  The names appear next to the code lines.
4.  Identify the culprit.

### Scenario 10: The "Cherry Pick" (I just want THAT change)
*Bob fixed a bug in `FileA` on `feature-branch`, you want it in `main`.*
1.  **VS:** View History. Select `feature-branch` from the dropdown.
2.  Find Bob's commit.
3.  Right-click -> **Cherry-Pick**.
4.  Git copies *just that commit* onto your current branch.

---

## 💀 PART 5: difficult Situations (Step-by-Step)

### Situation A: "I'm working on the wrong branch!"
*You coded for 2 hours and realized you are on `main` instead of `feature-x`.*
1.  DO NOT COMMIT.
2.  Click **Stash** (Save your work safely).
3.  Switch branch to `feature-x` (Bottom right corner of VS).
4.  Go to **Manage Stashes**.
5.  Right-click your stash -> **Apply**.
6.  Now your changes are on the correct branch.

### Situation B: "I deleted a file by accident!"
*You deleted `File2.txt` from disk.*
1.  Go to "Git Changes".
2.  You will see `File2.txt` under "Changes" with a "D" (Deleted) icon.
3.  Right-click it.
4.  **Undo Changes**.
5.  File is back.

### Situation C: "The History is a Mess!" (Squash)
*You made 5 commits: "fix", "fix again", "typo", "working now". You want 1 clean commit.*
1.  **VS:** View History.
2.  Select the last 5 commits (Hold Ctrl or Shift).
3.  Right-click -> **Squash Commits**.
4.  Edit the message to be one nice summary.
5.  Push.

---

## Final Rule
**"When in doubt, looking at the History graph usually solves the puzzle."**

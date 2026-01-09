# The Advanced Git CLI Guide: Mastering Linear History

## 🎯 Purpose
This guide is for the **Power User**. While your team clicks buttons, you will wield the command line to manipulate history with precision.
We focus on a **Linear Workflow** (Rebase-based), which keeps history clean and distinct, exactly like a well-managed TFS repo but with Git's distributed power.

---

## ⚙️ PART 1: The "Power" Configuration

Don't just install Git. Configure it to work *for* you.

### 1. The Golden Rule: Always Rebase
Stop "Merge Commits" from polluting your local history.
```bash
git config --global pull.rebase true
git config --global rebase.autoStash true
```
*   **`pull.rebase true`**: `git pull` becomes `fetch + rebase` instead of `fetch + merge`. You replay your work on top of the latest changes.
*   **`rebase.autoStash true`**: Dirty working directory? No problem. Git will stash your changes, pull, rebase, and pop them back automatically.

### 2. The "Must-Have" Aliases
Add these to your `~/.gitconfig` or run them:
```bash
git config --global alias.s "status -sb"   # Short status
git config --global alias.lg "log --oneline --graph --decorate --all" # The only log you need
git config --global alias.unstage "restore --staged"
git config --global alias.oops "commit --amend --no-edit" # Add forgotten files to last commit
```

---

## 🔄 PART 2: The Workflow Mechanics

### The "Mental Model"
In TFS, you "Check Out" -> "Check In".
In Git CLI (Linear), you:
1.  **Commit** to your local stack (infinite undo).
2.  **Fetch** the new "floor" (origin/main).
3.  **Rebase** (lift your stack, put it on the new floor).
4.  **Push** (publish the stack).

### The Commands
```bash
# 1. Start work
git checkout main
git pull

# 2. Make changes
vim feature.ts
git add .
git commit -m "feat: implement logic"

# 3. The "Get Latest" (Rebase)
git pull 
# (Because of config, this is actually 'fetch + rebase')

# 4. Push
git push origin main
```

---

## ⚔️ PART 3: Advanced Scenario Playbook

### Scenario A: The "Conflict" During Pull
You pulled, and `git` stopped.
```text
CONFLICT (content): Merge conflict in file.txt
error: could not apply...
```
**The Fix:**
1.  **Check Status:** `git s` (or `status`). It tells you exactly which files are red.
2.  **Edit Files:** Open them. Look for `<<<<<<< HEAD`, `=======`, `>>>>>>>`.
3.  **Resolve:** Delete markers, pick code, save.
4.  **Mark Resolved:** 
    ```bash
    git add file.txt
    ```
5.  **Continue Rebase:** (DO NOT COMMIT)
    ```bash
    git rebase --continue
    ```
    *Git will grab the next commit and try to apply it. Repeat if necessary.*

### Scenario B: The "Undo" (Precision Knife)

| Goal | Command | Explanation |
| :--- | :--- | :--- |
| **Undo file edits** (Unmodified) | `git restore file.ts` | Discard local changes. |
| **Unstage file** (Remove from Index) | `git restore --staged file.ts` | Keep changes, but remove from "Ready to Commit". |
| **Undo Last Commit** (Keep Work) | `git reset --soft HEAD~1` | The commit disappears. Files go back to Green (Staged). |
| **Undo Last Commit** (Destroy Work) | `git reset --hard HEAD~1` | **DANGER.** It is gone forever.* |
| **Undo Public Commit** (Rollback) | `git revert <commit-hash>` | Creates a new "Antimatter" commit. Safe for shared branches. |

*Actually, `git reflog` can save you from `reset --hard`. See below.*

### Scenario C: The "Interactive Clean-up" (Squash)
You made 3 commits: "WIP", "FIX", "DONE". You want one clean commit before pushing.
```bash
git rebase -i HEAD~3
```
An editor opens:
```text
pick a1b2c3d WIP
squash d4e5f6g FIX   <-- Change 'pick' to 's' or 'squash'
squash g7h8i9j DONE  <-- Change 'pick' to 's' or 'squash'
```
Save and close. Git combines them into one. You look like a genius who writes perfect code in one go.

### Scenario D: The "Reflog" (Time Travel)
You did a `git reset --hard` and lost 3 days of work.
**Don't Panic.** Git keeps a log of where HEAD *used to be*.
```bash
git reflog
```
Output:
```text
a1b2c3 HEAD@{0}: reset: moving to HEAD~1
b4c5d6 HEAD@{1}: commit: crucial feature logic  <-- THERE IT IS!
```
**The Rescue:**
```bash
git reset --hard HEAD@{1}
```
You are back to the future.

### Scenario E: Cherry-Picking (The Sniper)
You need *just* the bugfix from `feature-x` into `main`.
```bash
git checkout main
git cherry-pick <commit-hash-from-other-branch>
```
If conflicts happen, solve them -> `git add` -> `git cherry-pick --continue`.

### Scenario F: The "Worktree" (Multitasking)
Boss: "Fix this bug on Main NOW!"
You: "But I have 50 modified files on feature-login!"
**Old Way:** `git stash` -> switch -> fix -> `git stash pop`.
**Pro Way (Worktrees):**
Check out `main` into a *totally separate folder* alongside your current one.
```bash
git worktree add ../hotfix-folder main
```
Go to `../hotfix-folder`. It's a fresh repo pointed at main. Fix bug. Push. Delete folder.
Go back to your original folder. Nothing changed.


---

## 🛑 PART 4: Real-World Case Study: "The Rebase Hell" & How I Escaped It

**The Situation:**
I ran `git pull`. I expected a clean update. Instead, I got this:
```text
CONFLICT (add/add): Merge conflict in Git_VS_GUI_Workflow_Guide.md
error: could not apply...
hint: Resolve all conflicts manually... then run "git rebase --continue".
```

**Step 1: Don't Panic. Check Status.**
I immediately ran:
```bash
git status
```
Git told me:
> You are currently rebasing.
> Unmerged paths: `Git_VS_GUI_Workflow_Guide.md`

**Step 2: The Logic (Resolve the File)**
The file had conflict markers (`<<<<`, `====`).
I opened the file. I realized the "Generic" version was the correct one.
Instead of manually deleting lines, I simply overwrote the file with the correct content.
*Lesson:* You can edit the file however you want. Git just wants the *final* text.

**Step 3: Tell Git "I Fixed It"**
Once the file was saved, I ran:
```bash
git add Git_VS_GUI_Workflow_Guide.md
```
*Note: I did NOT run `git commit`. You are in the MIDDLE of a rebase.*

**Step 4: Continue the Rebase**
I ran:
```bash
git rebase --continue
```

**Step 5: The "Vim Trap" (Editor Issues)**
Git tried to open a text editor for the commit message. It got stuck in a weird state (or opened `vim` which is hard to exit).
*   **The Trick:** I forced Git to use `cat` (effectively "no editor, just accept the message").
    ```bash
    git -c core.editor=cat rebase --continue
    ```
    *   **Alternative:** If `vim` opens: Type `:wq` and hit Enter.

**Result:**
> `Successfully rebased and updated refs/heads/main.`
I was back in a clean state.

---


## 🧠 Deep Dive: What is actually happening?

### The "Index" (Staging Area)
Git has three zones:
1.  **Working Dir:** Your actual files.
2.  **Index (Stage):** The "shopping cart" for the next commit.
3.  **Repository:** The database of commits.

`git add` moves data from Zone 1 -> Zone 2.
`git commit` moves data from Zone 2 -> Zone 3.

### The Graph (DAG)
Git is just a Directed Acyclic Graph of snapshots.
*   **Branch:** Just a sticky note pointers to a specific commit hash.
*   **HEAD:** A pointer to the current Branch (or commit).
*   **Rebase:** Cutting the branch off the tree and grafting it onto a new spot.

## Final Cheat Sheet
*   **Getting new code:** `git pull` (Always rebase!)
*   **Saving state:** `git commit -am "msg"`
*   **Uploading:** `git push`
*   **Oh no:** `git status` (Read it!)
*   **Really Oh no:** `git reflog`

Master these, and you master the repository.

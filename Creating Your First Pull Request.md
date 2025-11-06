# 🌳 Creating Your First Pull Request: The VS Code Way 🚀

Welcome to the team! We're excited to have you contributing. This guide is for anyone who is new to Git or prefers to use the visual tools inside VS Code instead of the command line. No scary commands, just friendly buttons!

We use **Pull Requests** (PRs) to review code before it gets added to our main `master` branch. Think of it as asking a teammate, "Hey, can you double-check my work before we make it official?" It's a crucial part of writing great software together.

Let's walk through the entire process, step-by-step.

---

## The Workflow: From Idea to Pull Request

### ✅ Step 1: Get the Latest Code (Sync Up!)

Before you start writing any code, you need to make sure you have the most recent version of the project.

1.  Open the **Source Control** view by clicking its icon on the left-side activity bar.
    *   _It looks like this:_
    <img width="548" height="533" alt="image" src="https://github.com/user-attachments/assets/48b83436-86d1-4ba5-a145-fc997ee996f8" />

        
2.  Click the **`...`** menu at the top of the panel, go to **Pull, Push**, and select **Sync**. This downloads any updates your teammates have made and ensures you're starting from the right place.
    <img width="509" height="1036" alt="image (1)" src="https://github.com/user-attachments/assets/10b41136-6b01-42e9-8021-973c115ade40" />

> **Why we do this:** Starting with the latest code prevents a lot of headaches and messy conflicts later on!

### 🌱 Step 2: Create Your Own Branch

You should **never** work directly on the `main` or `master` branch. Instead, you'll create your own copy (a "branch") to work in safely.

1.  In the **Source Control** view, click on the current branch name (e.g., `main`).
    <img width="422" height="373" alt="image (2)" src="https://github.com/user-attachments/assets/1b8dbc85-e9ec-47f7-a524-584e2340c94b" />

2.  A menu will appear at the top. Click on **`+ Create new branch from...`**.
    <img width="1406" height="439" alt="image (3)" src="https://github.com/user-attachments/assets/fa4ebafe-857f-41de-84d6-9ba2b1396c25" />

3.  It will ask you to "Select a ref to create the branch from". **This is important!** Always choose the latest version of the main project branch, which is usually **`origin/main`** or `origin/master`.
    <img width="1431" height="445" alt="image (4)" src="https://github.com/user-attachments/assets/bbc7cf2a-fa97-4cfe-aad0-e7206c5eaecd" />

4.  Finally, give your branch a descriptive name and press `Enter`. Good names are like:
    *   `feat/add-user-login-page` (for a new feature)
    *   `fix/incorrect-tax-calculation` (for a bug fix)
    <img width="1421" height="420" alt="Screenshot 2025-11-06 152828" src="https://github.com/user-attachments/assets/b076d6f6-482c-492e-969e-e34bf48172e4" />


You are now on your new, safe branch!

> **Why we do this:** Your branch is your personal playground. If you make a mistake, it won't affect the main project. It keeps our main codebase clean and working at all times.

### 💻 Step 3: Make Your Code Changes

This is the fun part! Go ahead and create new files, edit existing ones, and build your feature or fix your bug. VS Code will automatically track everything you change and list them in the Source Control panel.

###  staging & committing Step 4: Stage and Commit Your Changes

A "commit" is a snapshot of your changes. It's like sealing a box and putting a clear label on it describing what's inside.

1.  In the Source Control view, look at the files under "Changes". Click the **`+`** icon next to each file you want to include in this snapshot. This moves them to "Staged Changes".
2.  In the "Message" box, write a clear, concise **commit message**.
    *   **Good Example:** `feat: Implement user password reset form`
    *   **Bad Example:** `stuff` or `more changes`
3.  Click the **Commit** button.
<img width="572" height="420" alt="image" src="https://github.com/user-attachments/assets/6971e21a-272c-4735-aa0f-591f09215d1c" />

### 🚀 Step 5: Push Your Branch (Share Your Work)

Your new branch and its commits are still only on your computer. You need to "push" it to the remote repository (Azure DevOps in our case) so others can see it.

1.  After you commit, a **"Publish Branch"** button will appear. Click it!
<img width="607" height="550" alt="image (5)" src="https://github.com/user-attachments/assets/e300cff2-f6ac-4320-aa08-267e20d4e8e5" />


This uploads your branch to the server. You can confirm this by looking at the `GRAPH` view, where you'll see your new branch has split off from `main` and now exists on the `origin` (the server).


### 📬 Step 6: Create the Pull Request in Azure DevOps

The final step! This is where you formally ask for your changes to be reviewed and merged.

1.  Go to your project's repository in Azure DevOps. The URL will look something like this:
    <img width="847" height="645" alt="image (7)" src="https://github.com/user-attachments/assets/6b2c09d3-56cb-4c51-8d42-9977ada3bd6a" />

2.  In the left-hand navigation pane, click on **Repos**.
   <img width="636" height="693" alt="image (8)" src="https://github.com/user-attachments/assets/6ec531e6-c7e0-4732-be42-f689ed091db5" />

4.  You have two easy options:
    *   Go to **Branches**. You will see your newly pushed branch listed, often with a count in the "Ahead" column. Azure DevOps usually shows a special icon or button here to create a PR.
        <img width="1868" height="845" alt="image (9)" src="https://github.com/user-attachments/assets/a3c61244-c8fd-4ee5-b4bf-cd6ec0e92b24" />

    *   Go directly to **Pull Requests** and click the "New pull request" button.
        <img width="598" height="657" alt="image (10)" src="https://github.com/user-attachments/assets/3a4ca301-b1f9-4ad8-8005-1cf73522497d" />


---

## 🚧 Guide in Progress! 🚧

This guide is currently being updated. The steps above cover creating and pushing your branch. The next section on **filling out the Pull Request form in Azure DevOps** is coming soon

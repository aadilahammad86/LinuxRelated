# How to Move a Directory with Full Git History to Another Repository

This guide provides a step-by-step process for moving a directory from one Git repository to another while preserving its entire commit history. This is useful for splitting a monolithic repository into smaller, more focused projects or for reorganizing codebases.

The primary tool used for this operation is `git filter-branch`, a powerful but destructive command. It is crucial to follow these steps carefully.

> **⚠️ Warning: History Rewriting Operation**
>
> This process involves rewriting Git history. Never perform these steps on a live, original repository. **Always work on a fresh, temporary clone** to avoid irreversible data loss. Ensure you have a backup of both repositories before you begin.

## Placeholders Used in This Guide

| Placeholder | Example | Description |
| :--- | :--- | :--- |
| `<SOURCE_REPO_URL>` | `git@github.com:user/source-repo.git` | The clone URL of the repository you are moving the directory **from**. |
| `<SOURCE_REPO_NAME>` | `source-repo` | The local directory name for the source repository clone. |
| `<DIRECTORY_TO_MOVE>` | `src/my-feature-module` | The path to the directory you want to move from the source repository. |
| `<DESTINATION_REPO_URL>` | `git@github.com:user/destination-repo.git` | The clone URL of the repository you are moving the directory **to**. |
| `<DESTINATION_REPO_NAME>`| `destination-repo` | The local directory name for the destination repository clone. |
| `<TEMPORARY_REMOTE_NAME>`| `source-history` | A short, temporary name for the remote connection to your prepared source repo. |
| `<BRANCH_NAME>` | `main` | The name of the primary branch in both repositories (e.g., `main` or `master`). |

---

## Phase 1: Prepare the Source Repository

In this phase, we will create a temporary, clean version of the source repository that contains *only* the directory and history we want to move.

### Step 1: Create a Fresh Clone of the Source Repository

Work in a clean directory to avoid confusion with existing projects.

```bash
# Clone the source repository into a new, temporary directory
git clone <SOURCE_REPO_URL>
cd <SOURCE_REPO_NAME>
```

### Step 2: Isolate the Directory and its History

This command rewrites the repository's history to make the specified subdirectory the new project root, effectively deleting everything else.

```bash
# This command can take a long time on large repositories.
git filter-branch --subdirectory-filter <DIRECTORY_TO_MOVE> -- --all
```
After this command completes, your repository will only contain the contents and history of `<DIRECTORY_TO_MOVE>`.

### Step 3 (Recommended): Move Content into a Subdirectory

To prevent file conflicts when merging into the destination repository, it's best to move the now root-level content into a new subdirectory. This ensures a clean merge.

```bash
# Create a new directory. This can be named the same as the original directory.
mkdir -p <DIRECTORY_TO_MOVE>

# Move all files and folders (except the new directory itself) into the new directory.
# This uses git mv to preserve history.
git mv -k * <DIRECTORY_TO_MOVE>/

# Note: The -k flag prevents git mv from moving the target directory into itself.
# Depending on your shell, you may need a more explicit command if you have dotfiles:
# for f in $(ls -A); do if [ "$f" != "<DIRECTORY_TO_MOVE>" ]; then git mv $f <DIRECTORY_TO_MOVE>/; fi; done
```

### Step 4: Commit the Changes

Commit the structural changes you just made. **Do not push this commit** to any remote server. This is a local, temporary change.

```bash
git commit -m "chore: Prepare directory for migration to new repository"
```

---

## Phase 2: Merge the History into the Destination Repository

Now, we'll go to the destination repository and pull in the prepared history.

### Step 5: Navigate to the Destination Repository

If you don't have a local copy, clone it now.

```bash
# Go back to the parent directory
cd ..

# Clone the destination repo if you haven't already
git clone <DESTINATION_REPO_URL>
cd <DESTINATION_REPO_NAME>
```

### Step 6: Add the Prepared Source Repository as a Remote

Create a temporary remote link to the local, modified source repository we prepared in Phase 1.

```bash
# The path should be a relative or absolute path to the local source clone
git remote add <TEMPORARY_REMOTE_NAME> ../<SOURCE_REPO_NAME>
```

### Step 7: Fetch and Merge the Histories

Fetch the data from the temporary remote and merge it. Because the two repositories do not share a common commit history, you must use the `--allow-unrelated-histories` flag.

```bash
# Fetch the commits from the prepared repository
git fetch <TEMPORARY_REMOTE_NAME>

# Merge the history into your destination repository's main branch
git merge --allow-unrelated-histories <TEMPORARY_REMOTE_NAME>/<BRANCH_NAME>
```

At this point, all the files and the complete Git history from `<DIRECTORY_TO_MOVE>` are now present in your destination repository.

---

## Phase 3: Clean Up and Finalize

The final steps are to remove the temporary connections and push your changes.

### Step 8: Remove the Temporary Remote

The link to the local source repository is no longer needed and should be removed to keep your destination repository clean.

```bash
git remote rm <TEMPORARY_REMOTE_NAME>
```

### Step 9: Push the Merged History

Push the newly combined history to your destination repository's origin.

```bash
git push origin <BRANCH_NAME>
```

### Step 10: Delete the Temporary Source Clone

The prepared source repository clone (`<SOURCE_REPO_NAME>`) served its purpose and can now be safely deleted.

```bash
# Navigate out of the destination repo
cd ..

# Remove the temporary source directory
rm -rf <SOURCE_REPO_NAME>
```

That's it! The process is complete.

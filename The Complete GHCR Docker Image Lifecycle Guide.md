# 🧱 **The Complete GHCR Docker Image Lifecycle Guide**

---

## 🚀 1️⃣ Prerequisites

Before you start:

* ✅ You have a **GitHub account**
* ✅ You have **Docker installed**
* ✅ You have **a working app** (e.g., .NET, Node.js, Python, etc.)
* ✅ You have a **GitHub repository** (to store your Dockerfile and code)

---

## 🧩 2️⃣ Folder and Dockerfile Setup

Your folder structure should look like this:

```
my-app/
 ├── Dockerfile
 ├── appsettings.json
 ├── bin/
 ├── wwwroot/
 └── MyApp.dll
```

### Example Dockerfile (generic .NET example)

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0

WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libfreetype6 \
    libgdiplus && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m app && chown -R app /app
USER app

EXPOSE 8080
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

---

## 🏗️ 3️⃣ Build the Docker Image

From the folder containing the Dockerfile:

```bash
docker build -t myapp:latest .
```

To confirm:

```bash
docker images
```

---

## 🧰 4️⃣ Test Locally

Run your image locally before publishing:

```bash
docker run -d -p 8080:8080 myapp:latest
```

Then visit → `http://localhost:8080`
✅ Verify it runs correctly.

---

## 🧠 5️⃣ Create a GitHub Repo

In GitHub:

* Create a new repo, e.g. `Docker_Stuff`
* Push your Dockerfile and related code there:

```bash
git init
git add .
git commit -m "Initial Docker setup"
git branch -M main
git remote add origin https://github.com/<username>/Docker_Stuff.git
git push -u origin main
```

---

## 🔑 6️⃣ Generate a Personal Access Token (PAT)

Go to:
👉 `GitHub → Settings → Developer settings → Personal Access Tokens → Tokens (classic) → Generate new token`

✅ **Select these scopes:**

* `read:packages` → allows pulling images
* `write:packages` → allows pushing images
* `delete:packages` → optional cleanup access
* `repo` → required if the repo is private

Copy the token (you won’t see it again).

---

## 🔐 7️⃣ Log in to GitHub Container Registry (GHCR)

```bash
echo YOUR_GITHUB_PAT | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

Example:

```bash
echo ghp_xxxxx | docker login ghcr.io -u username --password-stdin
```

✅ You should see:

```
Login Succeeded
```

---

## 📦 8️⃣ Tag the Image for GHCR

GitHub Container Registry uses this format:

```
ghcr.io/<USERNAME>/<IMAGE_NAME>:<TAG>
```

Example:

```bash
docker tag myapp:latest ghcr.io/username/docker_stuff:1.0.0
```

---

## ☁️ 9️⃣ Push to GHCR

```bash
docker push ghcr.io/username/docker_stuff:1.0.0
```

You’ll see:

```
The push refers to repository [ghcr.io/username/docker_stuff]
...
pushed: sha256:xxxxxxxxxxxx
```

---

## 🧩 10️⃣ Link the Image to Your GitHub Repo

This step is **done post-push** via the GitHub UI.

1. Go to:
   👉 `https://github.com/username?tab=packages`
2. Click your new package (`docker_stuff`)
3. On the right side → click **Package Settings**
4. Scroll down to **Repository Link**
5. Click **Connect Repository** → choose `Docker_Stuff`
6. Save changes ✅

Now your container package appears **inside the repo** under the “Packages” section.

---

## 🌍 11️⃣ (Optional) Make the Package Public

By default, GHCR packages are **private**.
If you want global pull access:

1. Go to the same package settings
2. Scroll to **“Danger Zone”**
3. Click **Change visibility → Public**

Now anyone can pull without logging in.

---

## 🧱 12️⃣ Pull & Run Anywhere

On any machine with Docker installed:

```bash
echo YOUR_GITHUB_PAT | docker login ghcr.io -u username --password-stdin
docker pull ghcr.io/username/docker_stuff:1.0.0
docker run -d -p 8080:8080 ghcr.io/username/docker_stuff:1.0.0
```

💡 If your image is public, you can skip the login step.

---

## 🧰 13️⃣ (Optional) Automate Builds via GitHub Actions

Create a workflow file in your repo:
`.github/workflows/docker-publish.yml`

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/docker_stuff:latest
```

Every commit → auto-builds → auto-publishes to GHCR 🚀

---

## 🧱 14️⃣ Security and Maintenance Best Practices

| Area                  | Recommendation                                               |
| --------------------- | ------------------------------------------------------------ |
| 🔐 **PATs**           | Store in a `.env` or use GitHub Secrets — never commit it.   |
| 🧩 **Image Size**     | Use multi-stage builds or `alpine` base to keep images lean. |
| 🧰 **Dependencies**   | Regularly update apt packages and .NET base image.           |
| ⚙️ **Access Control** | Keep GHCR private unless necessary to go public.             |
| 🧾 **Versioning**     | Tag images meaningfully (`v1.0.0`, `latest`, `dev`, `prod`). |
| ♻️ **Cleanup**        | Remove old, unused tags from GHCR to save space.             |

---

## ⚡ Lightning Takeaway

> Build → Tag → Push → Link → Run → Automate → Secure
> That’s the full Docker lifecycle for any app hosted on GitHub Packages.

---

Would you like me to create a **visual mind map version** of this guide (with stages, commands, and flow arrows) — something you can keep as a one-page reference diagram?

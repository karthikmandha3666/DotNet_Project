# Modern Web Project with Kubernetes & GitOps

Welcome to this full-scale, production-ready web application! 
This project is built with a **.NET Backend**, a **React/Vite Frontend**, and is designed to run securely and automatically on **Kubernetes** using a modern **Blue-Green** deployment strategy.

## 🏗️ What is inside?
Here is a very simple breakdown of how the folders work:
- `Backend/`: The server-side API application written in C# (.NET 9.0).
- `frontend/`: The user interface built with React and Vite.
- `database/`: SQL scripts to create your tables and initial data.
- `infrastructure/`: Terraform code to automatically rent servers and cloud services from Azure.
- `k8s/`: Configuration files that tell Kubernetes how to run the App (Deployments, Services, Load Balancers).
- `.github/workflows/`: Automation scripts that build and deploy the app every time you push code.
- `argocd/`: GitOps configuration to automatically sync your GitHub code to your live servers.

### 📄 File-by-File Explanation (For Beginners)

Here is what all the major files in those folders actually do:

**Docker (The Packager) 🐳**
- `Backend/Dockerfile`: A step-by-step recipe that packages your .NET C# code into an isolated, runnable "Docker Container".
- `frontend/Dockerfile`: A recipe that packages your React interface into a container, ready to be served by Nginx.
- `docker-compose.yml`: A master switch that turns on your database, backend, and frontend at the exact same time on your personal laptop.

**Terraform (The Cloud Builder) ☁️**
- `infrastructure/main.tf`: The script that physically asks Azure/AWS to create your servers and storage.
- `infrastructure/variables.tf`: Stores the configurable names (like "East US") for the things Terraform builds.

**Kubernetes (The Orchestrator) ☸️**
- `k8s/namespace.yaml`: Creates an isolated "room" (`webproject`) inside Kubernetes strictly for this app.
- `k8s/backend/deployment-blue.yaml`: Tells Kubernetes exactly how many copies (replicas) of your Backend to start.
- `k8s/backend/service.yaml`: An internal load balancer. It funnels internet traffic to the correct backend containers. 
- `k8s/ingress.yaml`: The main public door. It ensures that visitors going to `/api` hit the Backend, and visitors going to `/` hit the Frontend.

**Pipelines (The Automators) 🤖**
- `.github/workflows/ci-cd.yaml`: The GitHub Actions robot script. It automatically builds your code into Docker Images whenever you push to the `main` branch.
- `argocd/application.yaml`: The ArgoCD GitOps robot script. It constantly reads this GitHub project to keep your live servers perfectly synchronized with your YAML files.

---

## 🚀 How to Run Manually (For Beginners)

If you want to test everything on your own laptop without setting up the complex automation loop, follow these straightforward steps.

### Step 1: Run Locally with Docker
The absolute easiest way to start this project on your laptop is by using Docker Compose. You don't even need to install .NET or Node!
1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop).
2. Open a terminal in this main folder and run:
   ```bash
   docker-compose up --build
   ```
3. Your database, backend, and frontend will all instantly download, build, and start together on your computer.

### Step 2: Rent Cloud Servers (Terraform)
When you are ready to put this on the real internet, you need servers.
1. Install [Terraform](https://developer.hashicorp.com/terraform/downloads).
2. Go into the infrastructure folder in your terminal:
   ```bash
   cd infrastructure
   terraform init
   terraform apply
   ```
3. Type `yes`. Terraform will log into Azure and neatly build your cloud resources!

### Step 3: Put the App on the Servers (Kubernetes)
Now that your cloud exists, put your application code on it using Kubernetes files.
1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/).
2. Connect to your cluster and tell Kubernetes to start your apps:
   ```bash
   kubectl apply -f k8s/namespace.yaml
   kubectl apply -f k8s/backend/
   kubectl apply -f k8s/frontend/
   kubectl apply -f k8s/ingress.yaml
   ```

---

## 🤖 How to Run Automatically (CI/CD Pipeline)

In a real production company environment, humans shouldn't have to type commands manually every time. It happens entirely automatically!

### How the Automation Flow Works:
1. **Developer pushes code:** You finish writing a new feature in C# or React and merge it to the `main` branch.
2. **GitHub Actions builds it:** Our `.github/workflows/ci-cd.yaml` pipeline wakes up automatically. It securely packages your code into a "Docker Image" container and uploads it to the internet.
3. **GitHub updates the Manifests:** The pipeline then modifies your `deployment-blue.yaml` file to tell it exactly where you uploaded the new Docker Image, and commits that change back to GitHub.
4. **ArgoCD Applies it (GitOps):** A software robot sitting inside your cluster (ArgoCD) monitors your GitHub repository 24/7. It notices that the `deployment.yaml` file changed! It pulls down the new instructions and safely applies them to your servers. You did nothing but click "Merge"!

### The Blue/Green Deployment Magic ✨
When an automated update happens, the app doesn't shut down or face "Downtime". 
Kubernetes creates a completely new "Green" copy of your app running right next to the current live "Blue" copy. Only when the "Green" copy is 100% online, healthy, and tested does the `service.yaml` switch traffic over instantly. 
If the new code has a fatal bug, you just flip the switch back to "Blue"!

---

## 💡 Pro-Tips for Real Development (The "Missing" Pieces)

There are three critical industry practices that usually confuse beginners the most, which you'll eventually need to know:

### 1. Where do Passwords go? (Secrets Management) 🔐
You should **never** put real passwords (like the Database password in our `docker-compose.yml`) into Git. In a real production K8s cluster, you create **Kubernetes Secrets** or use a cloud vault (like Azure Key Vault). Your `deployment-blue.yaml` is designed to read these secure vaults and secretly hand the passwords to your application at startup.

### 2. Fast Editing (Hot Reloading) ⚡
While `docker-compose up` is amazing for testing the *finished* product, rebuilding Docker containers takes a minute. For your daily coding, you will usually:
- Open the `frontend` folder and run `npm run dev` (The webpage will instantly update the millisecond you hit "Save").
- Open the `Backend` folder and run `dotnet run` (or press Play in Visual Studio).
- You will usually only run the Database inside Docker locally.

### 3. Changing the Database (Migrations) 🗄️
The `init.sql` file creates your database the very first time. But what happens when you need to add a new "ProfilePicture" column 6 months from now? You shouldn't manually log into the live database to change it. Because you are using .NET, you will eventually use **Entity Framework (EF) Core Migrations** to safely and automatically upgrade your database structure during the CI/CD pipeline!

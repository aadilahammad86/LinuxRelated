# How to Create a New QAA Release in Azure DevOps

This guide provides step-by-step instructions on how to create a new release for the QAA (Quality Assurance and Analytics) environment within Azure DevOps.

## Prerequisites

*   You must have the necessary permissions in Azure DevOps to view and create releases.
*   A successful build artifact must exist to be deployed.

## Step-by-Step Instructions

Follow these steps to navigate to the correct release pipeline, select the appropriate build, and initiate a new release.

### 1. Navigate to Releases

*   From the main left-hand navigation menu in your Azure DevOps project, select **Pipelines**, and then click on **Releases**.

    <img width="582" height="696" alt="Screenshot 2025-11-17 004843" src="https://github.com/user-attachments/assets/1a695f2a-d395-4a43-b9bd-0015b4536dd7" />


### 2. Locate the QAA Pipeline Folder

*   In the list of pipeline folders, find and expand the folder named **QAA**.

    <img width="481" height="290" alt="Screenshot 2025-11-17 004854" src="https://github.com/user-attachments/assets/678f027c-e267-4d35-ae5d-ccb7afcc9100" />
    <br>
    <img width="380" height="776" alt="Screenshot 2025-11-17 004909" src="https://github.com/user-attachments/assets/382dbfb5-d933-42ca-8d84-2963ab2444d6" />



### 3. Select the Application Portal Pipeline

*   From the expanded list of pipelines within the QAA folder, select the **QAA_ApplicationPortal release pipeline**.

    <img width="1627" height="784" alt="Screenshot 2025-11-17 005021" src="https://github.com/user-attachments/assets/924fa5dc-de7d-4967-88d1-ad70a185d61b" />



### 4. Initiate a New Release

*   With the correct pipeline selected, click the **Create release** button located in the top-right corner of the window.

    <img width="1596" height="1020" alt="Screenshot 2025-11-17 005034" src="https://github.com/user-attachments/assets/44f31502-0219-4e7a-90d8-e3154daf97ee" />


### 5. Configure the Release

*   A "Create a new release" panel will appear on the right side of the screen.
*   Under the **Artifacts** section, you can select the version of the build you wish to deploy. By default, the latest successful build is selected.
*   If you need to deploy an older version, click the dropdown menu to see a list of available build versions and make your selection.

    <img width="849" height="754" alt="Screenshot 2025-11-17 005040" src="https://github.com/user-attachments/assets/b333393b-9c04-41f2-80cb-b09e82a53878" />



### 6. Create the Release

*   After confirming the build version, click the blue **Create** button at the bottom of the panel to start the release process.
*   <img width="493" height="182" alt="Screenshot 2025-11-17 005046" src="https://github.com/user-attachments/assets/d18035ab-95ea-40cd-95d2-9c6e8881f0aa" />


You have now successfully created a new release for the QAA Application Portal. You can monitor the progress of the deployment through the stages shown in the main window.

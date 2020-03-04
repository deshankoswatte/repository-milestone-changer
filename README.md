# repository-milestone-changer

### Prerequisites

You should have the following installed:
- Ballerina or you can download and install through https://ballerina.io/learn/installing-ballerina/.
- VSCode or you can download and install through https://code.visualstudio.com/download.
- Postman or you can download and install through https://www.postman.com/downloads/.

### Run the program

- Open the folder using VSCode.
- Change the values of variables: `ORGANIZATION_NAME`, `REPOSITORY_NAME`, `ACCESS_TOKEN` located at the `constants.bal` file.
- Run the program using the command using `ballerina run milestone_changer` on the root folder.
- Send a `PUT` request to http://localhost:9090/github-services/update-issues/{old-milestone-number}/{new-milestone-number} using Postman.

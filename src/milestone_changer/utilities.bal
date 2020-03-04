import ballerina/http;

# Processes the received request and update the issues.
#
# + issues - Issues with the specified milestone.
# + newMilestone - New milestone to be assigned. 
# + return - A boolean representing whether all the issues updated properly.
public function processRequest(json[] issues, string newMilestone) returns boolean | error {

    foreach json issue in issues {
        string issueNumber = issue.number.toString();
        json request = {
            "milestone": newMilestone
        };

        boolean updateStatus = updateIssue(request, issueNumber);

        if (!updateStatus) {
            return false;
        }
    }

    return true;
}


# Updates the issue milestone.
#
# + request - JSON request to be sent to the github API.
# + issueNumber - Issue number of the issue to be updated. 
# + return - A boolean representing whether the issue was updated.
function updateIssue(json request, string issueNumber) returns boolean {

    http:Request callBackRequest = new;
    callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber;

    callBackRequest.setJsonPayload(<@untained>request);
    http:Response | error gitHubResponse = gitHubAPIEndpoint->patch(<@untained>url, callBackRequest);

    if (gitHubResponse is http:Response) {
        if (gitHubResponse.statusCode == http:STATUS_OK) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

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

# Extract the milestone number from with the provided milestone name
#
# + milestoneName - Name of the milestone. 
# + return - Milestone number or an error if there's an error occurred during the extraction. 
public function extractMilestoneNumber(string milestoneName) returns @tainted string|error {

    http:Request callBackRequest = new;
    callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/milestones";

    http:Response | error gitHubResponse = gitHubAPIEndpoint->get(<@untained>url, callBackRequest);

    if (gitHubResponse is http:Response) {
        if (gitHubResponse.statusCode == http:STATUS_OK) {
            json|error jsonPayload = gitHubResponse.getJsonPayload();
            if (jsonPayload is json) {
                foreach json milestone in <json[]>jsonPayload {
                    if (milestone.title.toString() == milestoneName) {
                        return milestone.number.toString();
                    }
                }
                return error("Could not find a milestone with the given milestone name.");
            } else {
                return error(jsonPayload.reason());
            }
        } else {
            return error("Could not obtain the milestones of the specified repository.");
        }
    } else {
        return error(gitHubResponse.reason());
    }
}


# Updates the milestone of an issue.
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

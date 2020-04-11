import ballerina/http;

# Validates the received request.
#
# + request - Request which is received from the client. 
# + return - Data of the request if it is a valid request.
public function validateRequest(http:Request request) returns @tainted map<string>|error {

    var formParams = request.getFormParams();

    if (formParams is map<string>) {
        return formParams;
    } else {
        return error("Form parameter are not in the valid format.");
    }
}

# Processes the received request and update the issues.
#
# + issues - Issues with the specified milestone.
# + newMilestone - New milestone to be assigned. 
# + return - A boolean representing whether all the issues updated properly.
public function processRequest(json[] issues, string newMilestone) returns boolean|error {

    if (issues.length() > 0) {
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
    } else {
        return error("There are no issues with the specified milestone to be updated");
    }
}

# Extract the milestone number from with the provided milestone name
#
# + milestoneName - Name of the milestone. 
# + return - Milestone number or an error if there's an error occurred during the extraction. 
public function extractMilestoneNumber(string milestoneName) returns @tainted string|error {

    http:Request callBackRequest = new;
    callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/milestones";

    http:Response|error gitHubResponse = gitHubAPIEndpoint->get(<@untained>url, callBackRequest);

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
    http:Response|error gitHubResponse = gitHubAPIEndpoint->patch(<@untained>url, callBackRequest);

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

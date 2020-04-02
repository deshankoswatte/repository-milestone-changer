import ballerina/http;

http:Client gitHubAPIEndpoint = new (GITHUB_API_URL);
listener http:Listener servicesEndPoint = new (SERVICES_PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}

service githubService on servicesEndPoint {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/update-issues/"
    }
    resource function updateIssues(http:Caller caller, http:Request request) {

        http:Response response = new;
        map<string>|error validateRequestResult = validateRequest(request);

        if (validateRequestResult is map<string>) {

            ORGANIZATION_NAME = <@untained>validateRequestResult.get("organization_name");
            REPOSITORY_NAME = <@untained>validateRequestResult.get("repository_name");
            string oldMilestone = validateRequestResult.get("milestone_name_to_be_changed");
            string newMilestone = validateRequestResult.get("milestone_name_to_be_changed_to");
            ACCESS_TOKEN = "Bearer " + <@untainted>validateRequestResult.get("access_token").toString();

            http:Request callBackRequest = new;
            callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

            string|error oldMilestoneNumber = extractMilestoneNumber(oldMilestone);
            string|error newMilestoneNumber = extractMilestoneNumber(newMilestone);

            if (oldMilestoneNumber is string && newMilestoneNumber is string) {

                string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues?state=open&milestone=" + oldMilestoneNumber + "&per_page=100";
                http:Response|error gitHubResponse = gitHubAPIEndpoint->get(<@untained>url, callBackRequest);

                if (gitHubResponse is http:Response) {
                    if (gitHubResponse.statusCode == http:STATUS_OK) {
                        json|error jsonPayload = gitHubResponse.getJsonPayload();
                        if (jsonPayload is json) {
                            boolean|error processedRequest = processRequest(<json[]>jsonPayload, newMilestoneNumber);
                            if (processedRequest is boolean) {
                                if (processedRequest) {
                                    response.statusCode = http:STATUS_OK;
                                    response.setPayload("Milestones for the issues were updated successfully!");
                                } else {
                                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                    response.setPayload("Milestones for the issues were not updated successfully!");
                                }
                            } else {
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload(processedRequest.reason());
                            }
                        } else {
                            response.statusCode = http:STATUS_BAD_REQUEST;
                            response.setPayload(<@untained>jsonPayload.reason());
                        }
                    } else {
                        response.statusCode = gitHubResponse.statusCode;
                        response.setPayload("The github response status code was not at the acceptable status code of 200.");
                    }

                } else {
                    response.statusCode = http:STATUS_BAD_REQUEST;
                    response.setPayload(gitHubResponse.reason());
                }
            } else {
                response.statusCode = http:STATUS_BAD_REQUEST;
                response.setPayload("Could not extract milestone numbers from the specified milestone names.");
            }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setPayload(<@untained>validateRequestResult.reason());
        }

        error? respond = caller->respond(response);
    }
}

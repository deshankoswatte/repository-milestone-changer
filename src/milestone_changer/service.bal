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
        methods: ["PUT"],
        path: "/update-issues/{oldMilestone}/{newMilestone}"
    }
    resource function updateIssues(http:Caller caller, http:Request request, string oldMilestone, string newMilestone) {

        http:Request callBackRequest = new;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response response = new;

        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues?state=open&milestone=" + oldMilestone + "&per_page=100";
        http:Response | error gitHubResponse = gitHubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (gitHubResponse is http:Response) {
            if (gitHubResponse.statusCode == http:STATUS_OK) {
                json | error jsonPayload = gitHubResponse.getJsonPayload();
                if (jsonPayload is json) {
                    boolean | error processedRequest = processRequest(<json[]>jsonPayload, newMilestone);
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

        error? respond = caller->respond(response);
    }
}

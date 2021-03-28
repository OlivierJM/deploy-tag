require 'net/http'
require 'json'

# This has been tested and can be verified here:
#  - here https://gitlab.com/olivierjmm/gitlab-next-ci/-/releases
#  - https://gitlab.com/olivierjmm/gitlab-next-ci/-/tags

# get the env variables e.g: token
# this needs to be set in the terminal like 
# project_id = "13905080" # static id for platform project
@token = ENV['GITLAB_TOKEN']
@base_url = "https://gitlab.com/api/v4/projects/25486737" # testing with personal project
@auth = {'Authorization' => "Bearer #{@token}"}


# reusable get request handler 
def request_handler(url)
    tags_url = URI("#{@base_url}/#{url}")
    response = Net::HTTP.get(tags_url, @auth)
    formatted_response = JSON.parse(response)
    formatted_response
end

# fetch the last release in gitlab (tag)
# this is then used to determine the tag name for the next production deployment
def last_tag
    tags = request_handler("repository/tags")
    # here we are only interested in the last tag name
    tags.last["name"]
end

# get current tag name, convert it to a float, add one and return it back as a string
# TODO: => ruby is crazy with numbers such as "0.90" it returns 0.9, we could change our way of counting
# from 0 - 100 to be 0-10
def next_tag_name
    # do calculations as above and return new string
    last_tag
end

# fetch all stories that are marked as staging verified and are still open
# we will close these issues when we are done
def verified_tickets
    tickets = request_handler("issues?labels=Staging::Verified&state=opened")
    tickets
end

# format ticket listing to how we are currently doing it in gitlab https://handbook.doublegdp.com/prod-eng/engineering/#deployment
# returns a string of individual lines like this * #828 Add signature box on receipt https://gitlab.com/api/v4/projects/13905080/issues/828*
# since gitlab might not properly intepret new lines, we can later in the flow replace "\n" with "  "
# update👆🏾: changed to use both (double spaces and new line) to automatically format both messages and release_description
def format_verified_tickets
    verified = verified_tickets
    message = verified.map do |ticket|
        "##{ticket["iid"].to_s} #{ticket["title"]} #{ticket["_links"]["self"]}   \n"
    end
    message.join("")
end

# create a tag and attempt to fill up using the fetch stories above
# params needed for the tag  
# @param tag_name name or count of the tag, we will get this from last_tag + 1 with some parsing
# @param ref this is the name of the branch, this will be master
# @param message we are currently using this as a list of all verified issues in staging
# @param release_description currently we are building a markdown table with similar content as message above
# *release_description* is optional and was apparently deprecated in gitlab v11.7 and will be removed in v14
# current version is at v13.10
# ref: https://handbook.doublegdp.com/prod-eng/engineering/#deployment
def create_tag
    tag_post_url = URI("#{@base_url}/repository/tags")
    message = format_verified_tickets
    tag_name = next_tag_name

    Net::HTTP.start(tag_post_url.host, tag_post_url.port,
        :use_ssl => tag_post_url.scheme == 'https') do |http|
            request = Net::HTTP::Post.new(tag_post_url.path, 'Content-Type' => 'application/json')
            request['authorization'] = "Bearer #{@token}"
            request.body = {
                tag_name: "0.3", # TODO: use calculated version of next_tag_name
                ref: 'master',
                # message and release_description are basically the same, we should discuss
                message: message,
                release_description: message
            }.to_json
            res = http.request(request)
            puts "response #{res.body}"
    end
rescue => e
    puts "ooops  #{e}"
end

# after a successful creation of a tag, monitor if the deployment was successful, report back and close issues
# def close_tickets
    # get the most recent deployments or check one that was deployed today
    # if it has a status == "success" then go ahead and close issues
    # if it wasn't successful, no worries slack would've already notified
# end

create_tag
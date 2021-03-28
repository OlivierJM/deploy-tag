require 'net/http'
require 'json'

# get the env variables e.g: token
# this needs to be set in the terminal like 
token = ENV['GITLAB_TOKEN']
@base_url = "https://gitlab.com/api/v4/projects/13905080"
@auth = {'Authorization' => "Bearer #{token}"}


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


# fetch all stories that are marked as verified and are still open
def verified_tickets
    tickets = request_handler("issues?labels=Staging::Verified&state=opened")
    tickets
end

# create a tag and attempt to fill up using the fetch stories above

# Find the user who is currently logged and set as the who deployed

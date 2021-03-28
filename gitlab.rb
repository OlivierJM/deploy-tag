require 'net/http'
require 'json'

# get the env variables e.g: token
# this needs to be set in the terminal like 
token = ENV['GITLAB_TOKEN']
project_id = "13905080"
base_url = "https://gitlab.com/api/v4/projects/13905080"

# fetch the last release in gitlab (tag)
def last_tag
    tags_url = URI("#{base_url}/repository/tags")
    dep_response = Net::HTTP.get(tags_url, {'Authorization' => "Bearer #{token}"})
    convert = JSON.parse(dep_response)
    convert.last["name"]
end



# fetch all stories in current sprint that are marked as verified

# create a tag and attempt to fill up using the fetch stories above

# Find the user who is currently logged and set as the who deployed

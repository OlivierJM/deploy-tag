require 'net/http'
require 'json'

# get the env variables e.g: token
# this needs to be set in the terminal like 
token = ENV['GITLAB_TOKEN']
@base_url = "https://gitlab.com/api/v4/projects/13905080"
@auth = {'Authorization' => "Bearer #{token}"}

# fetch the last release in gitlab (tag)
def last_tag
    tags_url = URI("#{@base_url}/repository/tags")
    dep_response = Net::HTTP.get(tags_url, @auth)
    convert = JSON.parse(dep_response)
    convert.last["name"]
end

puts last_tag

labels = URI("#{@base_url}/labels")
labels_response = Net::HTTP.get(labels, @auth)
c = JSON.parse(labels_response)
puts c.last

# fetch all stories in current sprint that are marked as verified
def verified_tickets
    # GET /issues?labels=foo,bar
    tickets = URI("#{@base_url}/issues?labels=foo,bar")
    
end

# create a tag and attempt to fill up using the fetch stories above

# Find the user who is currently logged and set as the who deployed

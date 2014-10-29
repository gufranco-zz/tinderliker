# The MIT License (MIT)
#
# Copyright (c) 2014 Gustavo Franco
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
require "faraday"
require "faraday_middleware"
require "json"

FACEBOOK_ID = ENV["FACEBOOK_ID"]
FACEBOOK_TOKEN = ENV["FACEBOOK_TOKEN"]

# Connection
connection = Faraday.new(url: "https://api.gotinder.com") do |faraday|
  faraday.request :json
  faraday.adapter Faraday.default_adapter
end
connection.headers["User-Agent"] = "Tinder/4.0.4 (iPhone; iOS 7.1.1; Scale/2.00)"

# Authentication
authentication_response = connection.post "/auth", {facebook_token: FACEBOOK_TOKEN, facebook_id: FACEBOOK_ID}
authentication_response = JSON.parse(authentication_response.body)
connection.token_auth(authentication_response["token"])
connection.headers["X-Auth-Token"] = authentication_response["token"]

# Like
loop do
  user_list = connection.post "/user/recs"
  user_list = JSON.parse(user_list.body)
  if !user_list.nil?
    pool = []
    user_list["results"].each do |user|
      pool << Thread.new {
        connection.get "/get/#{user["_id"]}"
        puts user["_id"]
      }
    end
    pool.each(&:join)
  end
end

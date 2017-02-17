module StreamsHelper
  def streamUrlIsAudio?(url)
    url.to_s == "Stream".to_s
  end

  def streamUrlExist(url)
    puts "URL [#{url}]"

    begin
        response = RestClient.head(url)
        if response.code != 404
            data = "ACK!"
            data.html_safe
        else
            data = "NACK!"
            data.html_safe
        end
    rescue Exception => error
        data = "#{error}"
        data.html_safe
    end
  end

end

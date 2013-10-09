module Amazon
  module Web
    def self.url_encode(plaintext)
      CGI.escape(plaintext.to_s).gsub("+", "%20").gsub("%7E", "~")
    end
  end
end

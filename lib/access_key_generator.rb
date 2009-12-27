module KeyGenerator
  
  private
    def generate_key(codeLength = 9)
      validChars = ("A".."F").to_a + ("0".."9").to_a
      length = validChars.size

      hexCode = ""
      1.upto(codeLength) { |i| hexCode << validChars[rand(length-1)] }

      hexCode      
    end
    
end

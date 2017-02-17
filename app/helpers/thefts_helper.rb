module TheftsHelper
  def theftGenerateRadios(theft)
    begin
      puts "Afanando = #{theft}"
      puts "Afanando = #{theft.name}"

      puts "DONE!"
    rescue Exception => error
      puts "end #{error.class} and #{error.message}"
      
    end
  end
end

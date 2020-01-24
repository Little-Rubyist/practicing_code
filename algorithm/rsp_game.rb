#じゃんけん
def rock_scissor_paper_game(im) if (im.is_a? Integer) and (im <= 2)
                                  me = rand(3)
                                  if me === im
                                    p "あいこです"
                                  elsif (me - im === 1) or (me - im === -2)
                                    p "負けです"
                                  else p "勝ちです"
                                  end
                                end
end

rock_scissor_paper_game(2)
# 0 = "rock", 1 = "scissor", 2 = "paper"

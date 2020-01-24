def drop_block(bottom_field)
  change_line = bottom_field - 1
  @block_data[0].times do
    right_line_dot = @field_box[1] - @block_data[2] - @block_data[1]
    @field[change_line] = '.' * @block_data[2] + '#' * @block_data[1] + '.' * right_line_dot
    change_line -= 1
  end
end

def check_drop_block?
  check_line = 0
  @field_box[0].times do
    drop_left = @block_data[2]
    drop_right = @block_data[2] + @block_data[1] - 1
    # ラインを上から見ていって置けなくなるところが出たらdrop_block
    if !@field[-1].include?('#')
      drop_block(check_line)
      return
    elsif @block_data[1] == 1 && !@field[check_line][drop_left].include?("#")
      check_line += 1
      next
    elsif !@field[check_line][drop_left]..@field[check_line][drop_right].include?("#")
      # 置けるなら次の行
      check_line += 1
    else
      drop_block(check_line)
      return
    end
  end
end

def create_field
  @field_box = gets.split(' ').map { |int| int.to_i }
  @field = []
  @field_box[0].times do
    @field << "." * @field_box[1]
  end
end

def create_block
    @block_data = gets.split(' ').map { |data| data.to_i }
    check_drop_block?
end

create_field
@field_box[2].times do
  create_block
  puts @field
end

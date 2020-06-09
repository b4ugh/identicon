defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(image_struct) do
    [r, g, b | _tail] = image_struct.hex
    %Identicon.Image{image_struct | color: {r, g, b}}
  end

  def build_grid(image_struct) do
    grid =
      image_struct.hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image_struct | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(image_struct) do
    grid = Enum.filter image_struct.grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image_struct | grid: grid}
  end

  def build_pixel_map(image_struct) do
    pixel_map = Enum.map image_struct.grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image_struct | pixel_map: pixel_map}
  end

  def draw_image(image_struct) do
    canvas = :egd.create(250, 250)
    fill = :egd.color(image_struct.color)

    Enum.each image_struct.pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(canvas, start, stop, fill)
    end

    :egd.render(canvas)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end

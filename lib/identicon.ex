defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello()
      :world

  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    # input is actually the second image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)

  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do

    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      verticle = div(index, 5) * 50
      top_left = {horizontal, verticle}
      bottom_right = { horizontal + 50, verticle + 50 }
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) -> 
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
    hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    # this passes values and index of the list
    |> Enum.with_index
    %Identicon.Image{image | grid: grid}

  end

  def mirror_row(row) do
    [first, second | _tail]  = row
    row ++ [second, first]

  end

  # making a new struct with hex and image data
  # pattern matching via this argument.
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    # This is creatign a new record. This is not adding to the existing struct
    %Identicon.Image{image | color: {r, g, b}}
  end


  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    # same thing here. We're making a new image
    %Identicon.Image{hex: hex}
  end

end

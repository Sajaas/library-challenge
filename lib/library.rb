require 'yaml'
require 'pry'
require 'date'
require './lib/user.rb'
require './lib/user_input.rb'

class Library
  attr_accessor :collection, :current_user

  def initialize
    system "clear"
    @collection = YAML.load_file('./lib/book_data.yml')
    @input = User_input.new
  end

  def set_input_for_test(test_input)
    @input = test_input
  end

  def menu
    @exit = false

    while @exit == false

      menu_options
      n = @input.input_menu
      menu_choices(n)

      if @exit == false
        return_to_menu
      end
    end
  end

  #private
  def menu_choices(n)
    case n
    when 1 then user_name_input
    when 2 then list_books
    when 3 then search_author_input
    when 4 then borrow_menu
    when 5 then show_borrowed_books
    when 6 then exit_program
    else error_message_menu
    end
  end

  def menu_options
    puts '--- Welcome to the Library of Coming Books. Choose an option. ---
    1. to create an user or log in
    2. to list which books are available/unavailable
    3. to searching for an author
    4. to borrow an available book
    5. to show your borrowed books
    6. to exit'
  end

  def user_name_input
    puts 'Welcome to the library. Who are you?'
    username = @input.input_username
    create_user(username)
  end

  def create_user(username)
    @current_user = User.new(name: username)
    puts "Welcome #{@current_user.name}."
  end

  def list_books
    @collection.each do |title|
      if title[:available] == true
        puts "AVAILABLE: #{title[:item][:title]} by #{title[:item][:author]} (#{title[:item][:genre]})"
      else
        puts "NOT AVAILABLE: #{title[:item][:title]} by #{title[:item][:author]} (#{title[:item][:genre]}). Return date: #{title[:return_date]}"
      end
    end
  end

  def search_author_input
    puts 'Which author do you want to search for? Please enter first OR last name.'
    author = @input.input_search_author
    search_author(author)
  end

  def search_author(author)
    result = @collection.select { |obj| obj[:item][:author].include? author }
      if result.empty?
        error_message_no_match
      end
    result.each do |book|
      puts "#{book[:item][:title]} by #{book[:item][:author]} (#{book[:item][:genre]})"
    end
  end

  def borrow_menu
   if @current_user != nil
    show_books_menu
    index = @input.input_borrow_menu - 1
      if index < 0 || index >= @collection.length
        error_message_menu
      else
        borrow_book(index)
      end
    else
      error_message_no_user
    end
  end

  def show_books_menu
    puts 'Which book do you want to borrow? Enter the corresponding number.'
    @collection.each_with_index do |title, index|
    index_plus_one = index + 1
    if title[:available] == true
      puts "#{index_plus_one}. AVAILABLE: #{title[:item][:title]} by #{title[:item][:author]} (#{title[:item][:genre]})"
    else
      puts "#{index_plus_one}. NOT AVAILABLE UNTIL #{title[:return_date]}: #{title[:item][:title]} by #{title[:item][:author]} (#{title[:item][:genre]})"
    end
  end
end

def borrow_book(index)
  if @collection[index][:available] == true
    book_is_available(index)
  else
    book_is_unavailable(index)
  end
end

  def book_is_available(index)
    return_date(index)
    change_status(index)
    puts "You borrowed: #{@collection[index][:item][:title]} by #{@collection[index][:item][:author]}. Return by: #{@collection[index][:return_date]}!"
    @current_user.books << "#{@collection[index][:item][:title]} by #{@collection[index][:item][:author]} (return by #{@collection[index][:return_date]})"
  end

  def change_status(index)
    @collection[index][:available] = false
    File.open('./lib/book_data.yml', 'w') {|f| f.write @collection.to_yaml}
  end

  def return_date(index)
    @collection[index][:return_date] = Date.today.next_month.strftime("%d/%m/%y")
    File.open('./lib/book_data.yml', 'w') {|f| f.write @collection.to_yaml}
  end

  def book_is_unavailable(index)
    puts "#{@collection[index][:item][:title]} is unavailable. It will be returned by #{@collection[index][:return_date]}."
  end

  def show_borrowed_books
    if @current_user != nil && @current_user.books.any?
      puts @current_user.books
    elsif @current_user == nil
      error_message_no_user
    else
      error_message_no_borrowed_books
    end
  end

  def exit_program
    @exit = true
    puts 'Come back soon, there\'s lots to read here!'
  end

  def return_to_menu
    puts 'press ENTER to return to menu.'
    x = @input.input_return_to_menu
    system "clear"
  end

  def error_message_no_user
    puts 'Create an user or log in first!'
  end

  def error_message_menu
    puts 'Choose correct menu number, please.'
  end

  def error_message_no_match
    puts 'No matching author.'
  end

  def error_message_no_borrowed_books
    puts 'No books borrowed from here yet.'
  end
end

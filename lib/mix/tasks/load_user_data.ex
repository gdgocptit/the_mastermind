defmodule Mix.Tasks.LoadUserData do
  alias Nostrum.Struct.Guild.Integration.Account
  use Mix.Task

  @shortdoc "Load user data from CSV file into the database"

  alias TheMastermind.Repo
  alias TheMastermind.Account.User
  alias TheMastermind.Account

  def run(_args) do
    Mix.Task.run("app.start")
    # This will required priv/repo/dataset.csv file exists

    "priv/repo/dataset.csv" |> File.exists?() |> case do
      true -> :ok
      false ->
        Mix.shell().error("File priv/repo/dataset.csv does not exist.")
        System.halt(1)
    end

    "priv/repo/dataset.csv"
    |> File.read!()
    |> NimbleCSV.RFC4180.parse_string()
    |> Enum.map(fn [name, student_id] ->
      # the first column will be name, the second column will be student_id
      %User{
        name: name,
        student_id: student_id
      }
    end)
    |> Enum.each(fn user_struct ->
      case Account.exists_by_student_id?(user_struct.student_id) do
        true -> :ok
        false ->
          Repo.insert(user_struct)
          Mix.shell().info("Intertsed user with student_id: #{user_struct.student_id}, name: #{user_struct.name}")
      end
    end)
  end
end

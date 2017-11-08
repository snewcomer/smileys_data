defmodule SmileysData.State.Room.ActivityBucket do
  @moduledoc """
  A bucket representing all of a posts activity. Currently only contains a comment count
  """

  use GenServer, restart: :temporary

  @room_activity_hours_to_live 6

  alias SmileysData.State.Room.Activity

  @doc """
  Start with a new empty activity bucket
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: {:via, :syn, name})
  end

  def init(:ok) do  
    {:ok, %Activity{}}
  end

  # Client
  ##########################

  @doc """
  Get the activity map of a room
  """
  def get_activity(room_bucket) do
    GenServer.call(room_bucket, :retrieve)
  end

  @doc """
  Add new activity to a room
  """
  def increment_room_bucket_activity(room_bucket, %Activity{} = activity) do
    new_activity_state = GenServer.call(room_bucket, {:update, activity})

    set_activity_elimination_timer(room_bucket, activity)

    new_activity_state
  end

  @doc """
  Set a timer that reverses activity counts when complete
  """
  def set_activity_elimination_timer(room_bucket, %Activity{room: room, subs: subs, new_posts: new_posts, hot_posts: hot_posts}) do
    activity_reversed = %Activity{room: room, subs: subs * -1, new_posts: new_posts * -1, hot_posts: hot_posts * -1}

    Process.send_after(room_bucket, {:expire_activity, activity_reversed}, @room_activity_hours_to_live * 60 * 60 * 1000)
  end

  # Server
  ###########################
  def handle_call(:retrieve, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update, %Activity{subs: new_subs, new_posts: new_new_posts, hot_posts: new_hot_posts}}, _from, %Activity{room: room, subs: subs, new_posts: new_posts, hot_posts: hot_posts}) do
    new_activity_state = %Activity{room: room, subs: new_subs + subs, new_posts: new_new_posts + new_posts, hot_posts: new_hot_posts + hot_posts}
    {:reply, new_activity_state, new_activity_state}
  end

  def handle_info({:expire_activity, %Activity{subs: new_subs, new_posts: new_new_posts, hot_posts: new_hot_posts}}, %Activity{room: room, subs: subs, new_posts: new_posts, hot_posts: hot_posts}) do

    new_activity_state = %Activity{room: room, subs: new_subs + subs, new_posts: new_new_posts + new_posts, hot_posts: new_hot_posts + hot_posts}
    
    {:noreply, new_activity_state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
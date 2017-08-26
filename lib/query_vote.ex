defmodule SmileysData.QueryVote do

  require Ecto.Query

  alias SmileysData.{Post, Room, Vote, Repo}


  def upvote(post, user) do
  	changeset = Vote.changeset(%Vote{}, %{"username" => user.name, "postid" => post.id, "vote" => Integer.to_string(user.reputation)})

    # If greater than 3 days ago, no longer can vote
    postTime = DateTime.from_naive!(NaiveDateTime.from_iso8601!(NaiveDateTime.to_iso8601(post.inserted_at)), "Etc/UTC")

    if (((DateTime.utc_now() |> DateTime.to_unix()) - DateTime.to_unix(postTime, :second)) > 259200) do
      {:vote_time_over, 0}
    else
      # rep adjustment
      room = Room |> Repo.get_by(id: post.superparentid)
      
      SmileysData.QueryUser.update_user_reputation(post, user, room, 1)

      if post.voteprivate > 220 do
        SmileysData.QueryRoom.update_room_reputation(user, room, 1)
      end

      case Repo.insert(changeset) do
        {:ok, _vote} ->
          # TODO: refactor slightly to fix concurrency (update +=)
        	vote_total = post.voteprivate + user.reputation
          vote_total_alltime = post.votealltime + user.reputation
        	post_changeset = Post.changeset(post, %{"votepublic" => post.votepublic + 1, "voteprivate" => vote_total, "votealltime" => vote_total_alltime})

          _post_update = Repo.update(post_changeset)
          
          {:ok, 1}
        _ ->
          {:no_vote, 0}
      end
    end
  end

  def downvote(post, user) do
    changeset = Vote.changeset(%Vote{}, %{"username" => user.name, "postid" => post.id, "vote" => Integer.to_string(user.reputation * -1)})

    # If greater than 3 days ago, no longer can vote
    postTime = DateTime.from_naive!(NaiveDateTime.from_iso8601!(NaiveDateTime.to_iso8601(post.inserted_at)), "Etc/UTC")

    if (((DateTime.utc_now() |> DateTime.to_unix()) - DateTime.to_unix(postTime, :second)) > 259200) do
      {:vote_time_over, 0}
    else
      # rep adjustment
      room = Room |> Repo.get_by(id: post.superparentid)

      SmileysData.QueryUser.update_user_reputation(post, user, room, -1)

      if post.voteprivate > 220 do
        SmileysData.QueryRoom.update_room_reputation(user, room, -1)
      end

      case Repo.insert(changeset) do
        {:ok, _vote} ->
          vote_total = post.voteprivate - user.reputation
          post_changeset = Post.changeset(post, %{"votepublic" => post.votepublic - 1, "voteprivate" => vote_total, "votealltime" => vote_total})

          _post_update = Repo.update(post_changeset)
          {:ok, -1}
        _ ->
          {:no_vote, 0}
      end
    end
  end
end
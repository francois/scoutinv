class CreateQue < ActiveRecord::Migration[5.2]
  def up
    Que.migrate!(version: 4)
  end

  def down
    Que.migrate!(version: 0)
  end
end

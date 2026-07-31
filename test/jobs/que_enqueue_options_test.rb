require "test_helper"

class QueEnqueueOptionsTest < ActiveSupport::TestCase
  test "stores priority in job options instead of job arguments" do
    job = ShrinkImageJob.enqueue(1, 2, job_options: { priority: 0 })

    assert_equal 0, job.que_attrs[:priority]
    assert_equal [1, 2], job.que_attrs[:args]
    assert_equal({}, job.que_attrs[:kwargs])
  end

  test "stores a scheduled run time in job options" do
    run_at = 4.hours.from_now
    job = RemoveObsoleteMemberSessions.enqueue(job_options: { run_at: run_at })

    assert_in_delta run_at.to_f, job.que_attrs[:run_at].to_f, 1.second
    assert_equal [], job.que_attrs[:args]
    assert_equal({}, job.que_attrs[:kwargs])
  end
end

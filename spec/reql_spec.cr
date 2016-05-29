require "./spec_helper"

$reql_conn : RethinkDB::Connection
$reql_conn = r.connect({host: $rethinkdb_host})

struct ReqlMatchers
  def int_cmp(value)
    IntCmpMatcher.new(value.to_i64)
  end

  def float_cmp(value)
    FloatCmpMatcher.new(value.to_f64)
  end
end

def match_reql_output(result)
  result = result.to_a if result.is_a? RethinkDB::Cursor
  matcher = with ReqlMatchers.new yield
  if matcher.is_a? Matcher
    matcher.match(result)
  else
    result.should eq matcher
  end
end

describe RethinkDB do
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/bool.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/null.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/number.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/string.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/datum/typeof.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/add.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/div.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/floor_ceil_round.yaml", "#30.1", "#34.1") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/math.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/mod.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/mul.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/math_logic/sub.yaml") }}
  {{ run("./reql_spec_generator", "spec/rql_test/src/range.yaml") }}
end


abstract struct Matcher
end

struct IntCmpMatcher < Matcher
  def initialize(@value : Int64)
  end

  def match(result)
    result.should eq @value
    result.raw.should be_a Int64
  end
end

struct FloatCmpMatcher < Matcher
  def initialize(@value : Float64)
  end

  def match(result)
    result.should eq @value
    result.raw.should be_a Float64
  end
end

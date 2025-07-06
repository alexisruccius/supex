defmodule Supex.SynthTest do
  use ExUnit.Case, async: true

  alias Supex.Synth

  test "define synth" do
    name = "\\test"

    assert Synth.define(name) ==
             """
             SynthDef(#{name}, {
               arg freq=440,
               atk=0.005, sus=0.5, rel=0.3,
               sawiphase=0.7,
               moogmix=0.8, moogfreq=500, mooggain=1,
               pan=0, amp=1, out=0;
               var sig, env;
               sig = LFSaw.ar(freq, sawiphase) + Saw.ar(freq-1) + SinOsc.ar(freq+2);
               sig = XFade2.ar(sig, MoogFF.ar(sig, moogfreq, mooggain), moogmix*2-1);
               env = EnvGen.ar(Env.new([0, 1, 1, 0], [atk, sus, rel], [1, -1]), doneAction: 2);
               sig = Pan2.ar(sig, pan, amp);
               sig = sig * env;
               Out.ar(out, sig);
             }).play;
             """
             |> String.replace("\n", "")
  end
end

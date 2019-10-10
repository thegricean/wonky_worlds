function make_slides(f) {
  var   slides = {};

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

  slides.instructions = slide({
    name : "instructions",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.cause_effect_prior = slide({
    name : "cause_effect_prior",
    present : exp.all_stims,
    start : function() {
      $(".err").hide();
    },
    present_handle : function(stim) {
    	this.trial_start = Date.now();
      this.init_sliders();
      exp.sliderPost = null;
      $("#number_guess").html("?");
      this.stim = stim;
      console.log(stim.cause);
      if (stim.end_cause.length > 0) {
        var sentence = stim.name + " " + stim.beginning_cause + " 15 " + stim.object + " " + stim.end_cause + ".";
      } else {
        var sentence = stim.name + " " + stim.beginning_cause + " 15 " + stim.object + ".";
      }
      var question = "How many of the " + stim.object + " do you think " + stim.effect + "?";
      $("#sentence").html(sentence);
      $("#question").html(question);
      this.stim.sentence = sentence;
      this.stim.question = question;
    },
    button : function() {
      if (exp.sliderPost != null) {
        this.log_responses();
        _stream.apply(this); //use exp.go() if and only if there is no "present" data.
      } else {
        $(".err").show();
      }
    },
    init_sliders : function() {
      utils.make_slider("#single_slider", function(event, ui) {
        exp.sliderPost = Math.round(ui.value * 15);
        $("#number_guess").html(Math.round(ui.value * 15));
      });
    },
    log_responses : function() {
      exp.data_trials.push({
        "trial_type" : "cause_effect_prior",
        "object": this.stim.object,
        "object_level": this.stim.object_level,
        "cause": this.stim.cause,
        "effect": this.stim.effect,
        "name": this.stim.name,
        "gender" : this.stim.gender,
        "sentence" : this.stim.sentence,
        "question" : this.stim.question,
        "response" : exp.sliderPost,
        "rt" : Date.now() - this.trial_start
      });
    }
  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        asses : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
        comments : $("#comments").val(),
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {
      exp.data= {
          "trials" : exp.data_trials,
          "catch_trials" : exp.catch_trials,
          "system" : exp.system,
          "condition" : exp.condition,
          "subject_information" : exp.subj_data,
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}

/// init ///
function init() {

  var items = _.shuffle([
    {
      "object_low":"pencils",
      "object_mid":"crayons",
      "object_high":"ice cubes",
      "cause":"left __ in the hot sun",
      "effect":"melted"
    },
    {
      "object_low":"baseballs",
      "object_mid":"cakes",
      "object_high":"pieces of gum",
      "cause":"threw __ against a wall",
      "effect":"stuck to the wall"
    },
    {
      "object_low":"rocks",
      "object_mid":"books",
      "object_high":"matches",
      "cause":"threw __ into a fire",
      "effect":"burnt"
    },
    {
      "object_low":"backpacks",
      "object_mid":"hats",
      "object_high":"napkins",
      "cause":"left __ on a table on a windy day",
      "effect":"blew away"
    },
    {
      "object_low":"cd-players",
      "object_mid":"computers",
      "object_high":"flashlights",
      "cause":"pressed the 'on' button on __",
      "effect":"lit up"
    },
    {
      "object_low":"houses",
      "object_mid":"old cars",
      "object_high":"new cars",
      "cause":"left the lights on in __",
      "effect":"beeped"
    },
    {
      "object_low":"shoes",
      "object_mid":"shirts",
      "object_high":"books",
      "cause":"used __ as dog toys",
      "effect":"ripped"
    },
    {
      "object_low":"logs",
      "object_mid":"boxes",
      "object_high":"sunglasses",
      "cause":"ran __ over with a car",
      "effect":"broke"
    },
    {
      "object_low":"soda cans",
      "object_mid":"pinecones",
      "object_high":"banana peels",
      "cause":"put __ in a compost pile for a month",
      "effect":"decomposed"
    },
    {
      "object_low":"candles",
      "object_mid":"fireworks",
      "object_high":"gas tanks",
      "cause":"lit __",
      "effect":"exploded"
    },
    {
      "object_low":"carrots",
      "object_mid":"oreos",
      "object_high":"sugar cubes",
      "cause":"put __ in a bucket of water",
      "effect":"dissolved"
    },
    {
      "object_low":"beads",
      "object_mid":"sequins",
      "object_high":"stickers",
      "cause":"glued __ to a piece of paper",
      "effect":"stuck"
    },
    {
      "object_low":"bicyclists",
      "object_mid":"bus drivers",
      "object_high":"taxi drivers",
      "cause":"cut off __",
      "effect":"honked"
    },
    {
      "object_low":"lawyers",
      "object_mid":"comedians",
      "object_high":"kids",
      "cause":"told a joke to __",
      "effect":"laughed"
    },
    {
      "object_low":"dogs",
      "object_mid":"butterflies",
      "object_high":"birds",
      "cause":"left seeds out for __",
      "effect":"ate the seeds"
    },
    {
      "object_low":"phones",
      "object_mid":"bike lights",
      "object_high":"laptops",
      "cause":"left __ on (and unplugged) all day",
      "effect":"ran out of batteries"
    },
    {
      "object_low":"birthday cards",
      "object_mid":"love notes",
      "object_high":"novels",
      "cause":"wrote __",
      "effect":"had the letter Z in them"
    },
    {
      "object_low":"notebooks",
      "object_mid":"pancakes",
      "object_high":"coins",
      "cause":"tossed __",
      "effect":"landed flat"
    },
    {
      "object_low":"balloons",
      "object_mid":"cups",
      "object_high":"marbles",
      "cause":"threw __ into a pool",
      "effect":"sank"
    },
    {
      "object_low":"strawberries",
      "object_mid":"bananas",
      "object_high":"clovers",
      "cause":"saw __",
      "effect":"were green"
    },
    {
      "object_low":"white tablecloths",
      "object_mid":"white shirts",
      "object_high":"white carpets",
      "cause":"spilled red nail polish on __",
      "effect":"got stained"
    },
    {
      "object_low":"shelves",
      "object_mid":"block towers",
      "object_high":"card towers",
      "cause":"punched __",
      "effect":"fell down"
    },
    {
      "object_low":"phone screens",
      "object_mid":"diamonds",
      "object_high":"mirrors",
      "cause":"placed __ in the sun",
      "effect":"reflected the sunlight"
    },
    {
      "object_low":"poems",
      "object_mid":"songs",
      "object_high":"limericks",
      "cause":"wrote __",
      "effect":"rhymed"
    },
    {
      "object_low":"bicycles",
      "object_mid":"motorcycles",
      "object_high":"cars",
      "cause":"pressed the breaks on __",
      "effect":"stopped"
    },
    {
      "object_low":"toy cars",
      "object_mid":"shopping carts",
      "object_high":"wheelchairs",
      "cause":"pushed __",
      "effect":"rolled"
    },
    {
      "object_low":"bottles of hand soap",
      "object_mid":"chocolate bars",
      "object_high":"berries",
      "cause":"put __ in the freezer",
      "effect":"froze"
    },
    {
      "object_low":"webcams",
      "object_mid":"phones",
      "object_high":"cameras",
      "cause":"took a picture with __",
      "effect":"flashed"
    },
    {
      "object_low":"eggs",
      "object_mid":"balloons",
      "object_high":"bubbles",
      "cause":"poked __ with a pin",
      "effect":"popped"
    },
    {
      "object_low":"CDs",
      "object_mid":"balls of tin foil",
      "object_high":"eggs",
      "cause":"heated up __ in a microwave",
      "effect":"exploded"
    }
  ])

  var names = _.shuffle([
    {
      "name":"James",
      "gender":"M"
    },
    {
      "name":"John",
      "gender":"M"
    },
    {
      "name":"Robert",
      "gender":"M"
    },
    {
      "name":"Michael",
      "gender":"M"
    },
    {
      "name":"William",
      "gender":"M"
    },
    {
      "name":"David",
      "gender":"M"
    },
    {
      "name":"Richard",
      "gender":"M"
    },
    {
      "name":"Joseph",
      "gender":"M"
    },
    {
      "name":"Charles",
      "gender":"M"
    },
    {
      "name":"Thomas",
      "gender":"M"
    },
    {
      "name":"Christopher",
      "gender":"M"
    },
    {
      "name":"Daniel",
      "gender":"M"
    },
    {
      "name":"Matthew",
      "gender":"M"
    },
    {
      "name":"Donald",
      "gender":"M"
    },
    {
      "name":"Anthony",
      "gender":"M"
    },
    {
      "name":"Paul",
      "gender":"M"
    },
    {
      "name":"Mark",
      "gender":"M"
    },
    {
      "name":"George",
      "gender":"M"
    },
    {
      "name":"Steven",
      "gender":"M"
    },
    {
      "name":"Kenneth",
      "gender":"M"
    },
    {
      "name":"Andrew",
      "gender":"M"
    },
    {
      "name":"Edward",
      "gender":"M"
    },
    {
      "name":"Joshua",
      "gender":"M"
    },
    {
      "name":"Brian",
      "gender":"M"
    },
    {
      "name":"Kevin",
      "gender":"M"
    },
    {
      "name":"Ronald",
      "gender":"M"
    },
    {
      "name":"Timothy",
      "gender":"M"
    },
    {
      "name":"Jason",
      "gender":"M"
    },
    {
      "name":"Jeffrey",
      "gender":"M"
    },
    {
      "name":"Gary",
      "gender":"M"
    },
    {
      "name":"Ryan",
      "gender":"M"
    },
    {
      "name":"Nicholas",
      "gender":"M"
    },
    {
      "name":"Eric",
      "gender":"M"
    },
    {
      "name":"Jacob",
      "gender":"M"
    },
    {
      "name":"Jonathan",
      "gender":"M"
    },
    {
      "name":"Larry",
      "gender":"M"
    },
    {
      "name":"Frank",
      "gender":"M"
    },
    {
      "name":"Scott",
      "gender":"M"
    },
    {
      "name":"Justin",
      "gender":"M"
    },
    {
      "name":"Brandon",
      "gender":"M"
    },
    {
      "name":"Raymond",
      "gender":"M"
    },
    {
      "name":"Gregory",
      "gender":"M"
    },
    {
      "name":"Samuel",
      "gender":"M"
    },
    {
      "name":"Benjamin",
      "gender":"M"
    },
    {
      "name":"Patrick",
      "gender":"M"
    },
    {
      "name":"Jack",
      "gender":"M"
    },
    {
      "name":"Dennis",
      "gender":"M"
    },
    {
      "name":"Jerry",
      "gender":"M"
    },
    {
      "name":"Alexander",
      "gender":"M"
    },
    {
      "name":"Tyler",
      "gender":"M"
    },
    {
      "name":"Mary",
      "gender":"F"
    },
    {
      "name":"Jennifer",
      "gender":"F"
    },
    {
      "name":"Elizabeth",
      "gender":"F"
    },
    {
      "name":"Linda",
      "gender":"F"
    },
    {
      "name":"Emily",
      "gender":"F"
    },
    {
      "name":"Susan",
      "gender":"F"
    },
    {
      "name":"Margaret",
      "gender":"F"
    },
    {
      "name":"Jessica",
      "gender":"F"
    },
    {
      "name":"Dorothy",
      "gender":"F"
    },
    {
      "name":"Sarah",
      "gender":"F"
    },
    {
      "name":"Karen",
      "gender":"F"
    },
    {
      "name":"Nancy",
      "gender":"F"
    },
    {
      "name":"Betty",
      "gender":"F"
    },
    {
      "name":"Lisa",
      "gender":"F"
    },
    {
      "name":"Sandra",
      "gender":"F"
    },
    {
      "name":"Helen",
      "gender":"F"
    },
    {
      "name":"Ashley",
      "gender":"F"
    },
    {
      "name":"Donna",
      "gender":"F"
    },
    {
      "name":"Kimberly",
      "gender":"F"
    },
    {
      "name":"Carol",
      "gender":"F"
    },
    {
      "name":"Michelle",
      "gender":"F"
    },
    {
      "name":"Emily",
      "gender":"F"
    },
    {
      "name":"Amanda",
      "gender":"F"
    },
    {
      "name":"Melissa",
      "gender":"F"
    },
    {
      "name":"Deborah",
      "gender":"F"
    },
    {
      "name":"Laura",
      "gender":"F"
    },
    {
      "name":"Stephanie",
      "gender":"F"
    },
    {
      "name":"Rebecca",
      "gender":"F"
    },
    {
      "name":"Sharon",
      "gender":"F"
    },
    {
      "name":"Cynthia",
      "gender":"F"
    },
    {
      "name":"Kathleen",
      "gender":"F"
    },
    {
      "name":"Ruth",
      "gender":"F"
    },
    {
      "name":"Anna",
      "gender":"F"
    },
    {
      "name":"Shirley",
      "gender":"F"
    },
    {
      "name":"Amy",
      "gender":"F"
    },
    {
      "name":"Angela",
      "gender":"F"
    },
    {
      "name":"Virginia",
      "gender":"F"
    },
    {
      "name":"Brenda",
      "gender":"F"
    },
    {
      "name":"Catherine",
      "gender":"F"
    },
    {
      "name":"Nicole",
      "gender":"F"
    },
    {
      "name":"Christina",
      "gender":"F"
    },
    {
      "name":"Janet",
      "gender":"F"
    },
    {
      "name":"Samantha",
      "gender":"F"
    },
    {
      "name":"Carolyn",
      "gender":"F"
    },
    {
      "name":"Rachel",
      "gender":"F"
    },
    {
      "name":"Heather",
      "gender":"F"
    },
    {
      "name":"Diane",
      "gender":"F"
    },
    {
      "name":"Joyce",
      "gender":"F"
    },
    {
      "name":"Julie",
      "gender":"F"
    },
    {
      "name":"Emma",
      "gender":"F"
    }
  ])

  function makeStim(i) {
    //get item
    var item = items[i];
    //get name
    var name_data = names[i];
    var name = name_data.name;
    var gender = name_data.gender;
    //get level
    var object_level = _.shuffle(["object_low", "object_mid", "object_high"])[0];
    //get pronouns
    var nom = gender == "M" ? "he" : "she";
    var acc = gender == "M" ? "him" : "her";
    var gen = gender == "M" ? "his" : "her";
    //get cause and effect elements
    var cause = item.cause;
    var effect = item.effect;
    var object = item[object_level];
    var cause_elements = cause.split("__");
    var beginning_cause = cause_elements[0];
    var end_cause = cause_elements.length > 1 ? cause_elements[1] : "";
    return {
      "name": name,
      "gender": gender,
      "object_level": object_level,
      "nom": nom,
      "acc": acc,
      "gen": gen,
      "cause": cause,
      "effect": effect,
      "object": object,
      "beginning_cause": beginning_cause,
      "end_cause": end_cause
    }
  }
  exp.all_stims = [];
  for (var i=0; i<items.length; i++) {
    exp.all_stims.push(makeStim(i));
  }

  exp.trials = [];
  exp.catch_trials = [];
  exp.condition = {}; //can randomize between subject conditions here
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure=["i0", "instructions", "cause_effect_prior", 'subj_info', 'thanks'];
  
  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
                    //relies on structure and slides being defined
  $(".nQs").html(exp.nQs);

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
    if (turk.previewMode) {
      $("#mustaccept").show();
    } else {
      $("#start_button").click(function() {$("#mustaccept").show();});
      exp.go();
    }
  });

  exp.go(); //show first slide
}
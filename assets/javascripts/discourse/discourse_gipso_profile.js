// assets/javascripts/discourse/custom_feedback.js
console.log("discourse gipso profile js geladen");
Discourse.Route.add("/gipso/validate", {
  path: "/gipso/validate",
  controller: "discourse_gipso_profile"
});


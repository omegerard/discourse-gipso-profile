export default {
  name: "observe-save-feedback",

  initialize() {
    console.log("Custom Feedback Plugin is loaded!");

    document.addEventListener("DOMContentLoaded", () => {
      console.log("DOM is volledig geladen!");

      const observer = new MutationObserver((mutationsList) => {
        for (const mutation of mutationsList) {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === 1 && node.matches(".controls.save-button")) {
              console.log("Save-button-div gevonden via observer:", node);

              // Probeer saveButton te definiëren
              try {



                const saveButton = node.querySelector(".save-changes");
                if (saveButton) {
                  console.log("Save-button gevonden:", saveButton);
                  observer.disconnect(); // Observer stoppen als het element is gevonden


                  // Voeg een eventlistener toe aan de save-knop
                  saveButton.addEventListener("click", () => {
                    console.log("Save-button is ingedrukt!");

                    // Start een tweede observer gericht op het '.saved' element
                    const feedbackObserver = new MutationObserver((feedbackMutations) => {
                      feedbackMutations.forEach((feedbackMutation) => {
                        if (
                          feedbackMutation.target &&
                          feedbackMutation.target.matches(".saved")
                        ) {
                          console.log("Mutation gedetecteerd in '.saved':", feedbackMutation);

			  fetch("/gipso/validate", {
  			    method: "GET",
  			    headers: {
    			      "Content-Type": "application/json"
  			    }
  			  })
                            .then((response) => {
                              if (!response.ok) {
                                throw new Error("Network response was not ok");
                              }
                              return response.json();
                            })
                            .then((data) => {
                              console.log("Feedback ontvangen van server:", data);

                              //const message = data.message || "gebruiker";
                              //console.log("Dit is de boodschap: ", message);

                              // Gebruik beide waarden in de feedback
                              const feedbackMessage = data.message;
                              console.log("Dit is de feedbackMessage: ", feedbackMessage);

                              // Pas de feedback aan in de DOM
                              const savedSpan = feedbackMutation.target;
                              savedSpan.textContent = feedbackMessage;
                              savedSpan.style.display = "inline";

                              // Stop de feedback observer na succesvolle toepassing
                              feedbackObserver.disconnect();
                              console.log("Feedback observer gestopt.");
                            })
                            .catch((error) => {
                              console.error("Fout bij het ophalen van feedback:", error);
                            });
                        }
                      });
                    });

                    // Observeer veranderingen in de '.saved' span
                    feedbackObserver.observe(document.body, {
                      childList: true,
                      subtree: true,
                      characterData: true,
                    });
                  });
                } else {
                  console.warn("Save-button niet gevonden binnen de save-button-div.");
                }
              } catch (error) {
                console.error("Fout bij het definiëren van saveButton:", error);
              }
            }
          });
        }
      });

      // Observeer de hele body om mutaties op te pikken
      observer.observe(document.body, { childList: true, subtree: true });
    });
  },
};


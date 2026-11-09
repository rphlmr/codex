/** Apply approval events without performing I/O. */
export function transitionApproval(state, event) {
  switch (state.phase) {
    case "draft": {
      if (event.type === "approval.submit" && state.text.trim() !== "") {
        return [{ phase: "pending", text: state.text }, [{ type: "review.request", text: state.text }]];
      }

      if (event.type === "draft.edit") {
        return [{ phase: "draft", text: event.text }, []];
      }

      break;
    }

    case "pending": {
      if (event.type === "approval.accept") {
        return [{ phase: "approved", text: state.text }, [{ type: "publication.enqueue", text: state.text }]];
      }

      if (event.type === "approval.reject") {
        return [{ phase: "draft", text: state.text }, []];
      }

      break;
    }

    case "approved": {
      break;
    }
  }

  return [state, []];
}

/** Own state changes and execute only effects authorized by the transition. */
export function createApprovalController(runEffect) {
  let approvalState = { phase: "draft", text: "" };

  return {
    getState() {
      return { ...approvalState };
    },

    send(event) {
      const [nextState, effects] = transitionApproval(approvalState, event);
      approvalState = nextState;

      for (const effect of effects) {
        runEffect(effect);
      }
    },
  };
}

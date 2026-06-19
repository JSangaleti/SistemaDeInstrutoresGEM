package com.gem.backend.validation;

import jakarta.validation.groups.Default;

public final class ValidationGroups {

    private ValidationGroups() {
    }

    public interface Create extends Default {
    }
}

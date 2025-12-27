package hu.elte.inf.yang.parser.definitions;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class YangModule {
    public static final String YANG_VERSION = "1.1";

    private String moduleName;
}

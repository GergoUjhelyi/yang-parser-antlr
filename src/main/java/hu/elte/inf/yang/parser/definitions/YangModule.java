package hu.elte.inf.yang.parser.definitions;

public class YangModule {

    public static final String YANG_VERSION = "1.1";

    private String moduleName;


    public String getModuleName() {
        return moduleName;
    }

    public void setModuleName(String moduleName) {
        this.moduleName = moduleName;
    }
}

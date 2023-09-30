<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "header">
        ${msg("logoutConfirmTitle")}
    <#elseif section = "form">
                <p class="instruction">${msg("logoutConfirmHeader")}</p>
                <form class="form-actions" action="${url.logoutConfirmAction}" method="POST">
                                <input type="hidden" name="session_code" value="${logoutConfirm.code}">
                                <div class="${properties.kcFormGroupClass!}">
                                    <div id="kc-form-options">
                                        <div class="${properties.kcFormOptionsWrapperClass!}">
                                        </div>
                                    </div>

                                    <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                                        <input tabindex="4"
                                               class="btn btn-ptm-primary mt-3 w-100"
                                               name="confirmLogout" id="kc-logout" type="submit" value="${msg("doLogout")}"/>
                                    </div>

                                </div>
                            </form>

                            <div id="kc-info-message">
                                <#if logoutConfirm.skipLink>
                                <#else>
                                    <#if (client.baseUrl)?has_content>
                                        <p class="float-end m-0 mt-3"><a href="${client.baseUrl}">${kcSanitize(msg("backToApplication"))?no_esc}</a></p>
                                    </#if>
                                </#if>
                            </div>
    </#if>
</@layout.registrationLayout>
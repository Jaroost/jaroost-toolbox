//pour jquery file upload (le template aussi)
import tmpl from 'blueimp-tmpl/js/tmpl'
window.tmpl=tmpl;
// import 'blueimp-file-upload/js/vendor/jquery.ui.widget'
// import 'blueimp-file-upload/js/jquery.iframe-transport'
// import 'blueimp-file-upload/js/jquery.fileupload'
//pour afficher les images directement à l'upload
import loadImage from 'blueimp-load-image'
window.loadImage=loadImage;

//permet d'utiliser les traductions rails dans le javascript
import {I18n} from 'i18n-js'
import fr from "../translations/fr.json";
import en from "../translations/en.json";
import grids_fr from "@ptm/vue-grids/translations_fr.json"
import grids_en from "@ptm/vue-grids/translations_en.json"
import rfdcPackage from "rfdc";
window.rfdc = rfdcPackage();
const rfdc = window.rfdc;

/**
 * This function will accept the two objects as arguments and return the object of deeply
 * merged with nested properties.
 * @param {object} targetObject objects containing the properties to be merged with source.
 * @param {object} sourceObject objects containing the properties you want to apply.
 * @return {object} return the deeply merged objects
 * C.f. : https://medium.com/@srajas02/merge-two-objects-deeply-nested-in-javascript-8e8515b4f8d3
 */
function deepMergeObject(targetObject = {}, sourceObject = {}) {
    // clone the source and target objects to avoid the mutation
    const copyTargetObject = rfdc(targetObject);
    const copySourceObject = rfdc(sourceObject);
    // Iterating through all the keys of source object
    Object.keys(copySourceObject).forEach((key) => {
        if (typeof copySourceObject[key] === "object" && !Array.isArray(copySourceObject[key])) {
            // If property has nested object, call the function recursively
            copyTargetObject[key] = deepMergeObject(
                copyTargetObject[key],
                copySourceObject[key]
            );
        } else {
            // else merge the object source to target
            copyTargetObject[key] = copySourceObject[key];
        }
    });

    return copyTargetObject;
}
const i18n = new I18n({
    ...deepMergeObject(fr, grids_fr),
    ...deepMergeObject(en, grids_en),
});
i18n.defaultLocale=window.rubyI18nDefaultLocale
i18n.locale=window.rubyI18nLocale

i18n.humanizeDuration = function(duration){
    if(duration === ""){
        return duration
    }

    const UNIT_TO_DEFINITION = {
        Y: 'year',
        M: 'month',
        W: 'week',
        D: 'day',
        H: 'hour',
        MT: 'minute',
        S: 'second'
    }

    let dividers = [
        31556952, // seconds per year
        2629746, //seconds per month 1/12 of a gregorian year
        604800, //seconds per week
        86400, //seconds per day
        3600, //seconds per hour
        60, //seconds per minute
        1 //seconds
    ]
    let durationObj = {year: 0, month: 0, week: 0, day: 0, hour: 0, minute: 0, second: 0}

    if(parseInt(duration) > 0){
        Object.keys(durationObj).forEach((key, index) => {
            let divider = dividers[index];
            durationObj[key] = Math.floor(duration/divider);
            duration = duration % divider;
        })
    } else if(typeof duration === 'object') {
        durationObj[UNIT_TO_DEFINITION[duration.unit]] = duration.quantity;
    } else {
        let extracted = duration.match(/^P(?<time>T)?(?<quantity>\d*(\.\d*)?)(?<unit>[YMWDHS])$/).groups
        let key = UNIT_TO_DEFINITION[extracted.time && extracted.unit === 'M' ? 'MT' : extracted.unit]
        durationObj[key] = parseInt(extracted.quantity)
    }

    duration = Object.entries(durationObj).filter(([key, value]) => value !== 0).map(([key, value]) => {
        return i18n.t(`datetime.distance_in_words.x_${key}s`, {count: value})
    })

    switch(true){
        case (duration.length === 1):
            duration = duration[0];
            break;
        case (duration.length === 2):
            duration = duration.join(i18n.t('support.array.two_words_connector'));
            break;
        case (duration.length > 0):
            let words_connector = i18n.t('support.array.words_connector');
            duration = duration.join(words_connector);
            let index = duration.lastIndexOf(words_connector);
            duration = duration.substring(0,index) + i18n.t('support.array.last_word_connector') + duration.substring(index+1)
            break;

    }

    return duration;
}
//permet de rendre disponible I18n pour le navigateur
window.I18n=i18n
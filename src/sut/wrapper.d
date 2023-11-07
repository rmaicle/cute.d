/**
 * Module that encapsulates the inclusion of the selective unit test
 * module at compile-time.
 *
 * Internal use only.
 * This module is used only when unit testing the SUT module.
 */
module sut.wrapper;

version (sut) {

    /**
     * Conditionally compile-in the `sut` internal modules necessary.
     */
    static import sut.mixins;
    static import sut.stats;

    /**
     * Unit test block prologue code mixed-in from unit test blocks.
     */
    enum prologue=`mixin (sut.mixins.prologueBlock);`;

} else {

    enum prologue=string.init;

}
